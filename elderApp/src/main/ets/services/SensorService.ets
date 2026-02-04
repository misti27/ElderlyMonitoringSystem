import sensor from '@ohos.sensor';
import { BusinessError } from '@ohos.base';
import {
  AccelerometerData,
  AccelerometerModel,
  ActivityStatus,
  Constants,
  FallType,
  ElderlyStatusModel
} from 'shared';
import { elderlyStore } from '../models/ElderlyStore';

/**
 * 传感器采集服务
 */
export class SensorService {
  private static instance: SensorService;

  // 1. 核心属性
  private lastAccData: AccelerometerData = new AccelerometerData();
  private accDataHistory: AccelerometerData[] = [];
  private lastFallTime: number = 0;
  private readonly HISTORY_LIMIT: number = 50; // 维持最近50帧数据（约1-5秒，取决于采样频率）

  private constructor() {}

  static getInstance(): SensorService {
    if (!SensorService.instance) {
      SensorService.instance = new SensorService();
    }
    return SensorService.instance;
  }

  // ==========================================
  // 【数据出口】供 UI 组件（如 SensorInfo）调用
  // ==========================================

  /**
   * 获取最新的单条加速度数据（修复之前的报错）
   */
  public getLastAccData(): AccelerometerData {
    return this.lastAccData;
  }

  /**
   * 获取加速度历史序列（方便算法队友分析波动）
   */
  public getAccHistory(): AccelerometerData[] {
    return this.accDataHistory;
  }

  // ==========================================
  // 【生命周期管理】
  // ==========================================

  startCollecting(): void {
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
        this.handleAccelerometerData(data);
      }, { interval: Constants.SENSOR.SAMPLE_INTERVAL });

      elderlyStore.startCollecting();
      console.info('传感器采集已启动');
    } catch (err) {
      const error = err as BusinessError;
      console.error('启动传感器采集失败: ' + error.message);
    }
  }

  stopCollecting(): void {
    try {
      sensor.off(sensor.SensorId.ACCELEROMETER);
      elderlyStore.stopCollecting();
      console.info('传感器采集已停止');
    } catch (err) {
      console.error('停止传感器采集失败');
    }
  }

  // ==========================================
  // 【核心逻辑】数据处理与算法调度
  // ==========================================

  private handleAccelerometerData(data: sensor.AccelerometerResponse): void {
    try {
      // 1. 封装数据
      const model: AccelerometerModel = {
        x: data.x,
        y: data.y,
        z: data.z,
        timestamp: Date.now()
      };
      const accData = new AccelerometerData(model);

      // 2. 更新内存缓存（用于 UI 显示和历史分析）
      this.lastAccData = accData;
      this.accDataHistory.push(accData);
      if (this.accDataHistory.length > this.HISTORY_LIMIT) {
        this.accDataHistory.shift();
      }

      // 3. 将数据同步到全局 Store（触发 UI 更新）
      elderlyStore.addSensorData(accData);

      // 4. 计算运动状态（行走、静止）
      const activityStatus = this.detectActivityStatus(accData);

      // 5. 【算法接入】调用跌倒检测
      const fallType = this.runFallDetectionAlgorithm(accData);
      const isFall = (fallType !== FallType.NONE);

      // 6. 更新 Store 状态
      const statusUpdate: ElderlyStatusModel = {
        activityStatus: activityStatus,
        isFall: isFall,
        fallType: fallType
      };
      elderlyStore.updateStatus(statusUpdate);

    } catch (err) {
      console.error('处理加速度数据异常');
    }
  }

  /**
   *  检测简单的运动状态
   */
  private detectActivityStatus(data: AccelerometerData): ActivityStatus {
    const magnitude = Math.sqrt(data.x * data.x + data.y * data.y + data.z * data.z);
    const dynamicAcc = Math.abs(magnitude - 9.8); // 减去重力加速度

    if (dynamicAcc < Constants.SENSOR.STILL_THRESHOLD) {
      return ActivityStatus.STILL;
    } else if (dynamicAcc < 2.0) {
      return ActivityStatus.WALKING;
    } else {
      return ActivityStatus.RUNNING;
    }
  }

  /**
   * 跌倒检测
   */
  private runFallDetectionAlgorithm(currentData: AccelerometerData): FallType {
    // A. 冷却时间判断（跌倒后5秒内不重复触发，避免刷屏）
    const now = Date.now();
    if (now - this.lastFallTime < 5000) {
      return FallType.NONE;
    }

    // B. 获取历史窗口（有些算法需要看前 10 帧数据来判断姿态）
    // const history = this.getAccHistory();

    // C. 基础阈值判断（队友可以在此替换更复杂的算法）
    const magnitude = Math.sqrt(currentData.x ** 2 + currentData.y ** 2 + currentData.z ** 2);

    // 如果超过设定的 2.5G 阈值（可在 Constants 调整）
    if (magnitude > Constants.SENSOR.FALL_THRESHOLD * 9.8) {
      this.lastFallTime = now;

      /**
       * 1. 如果 Z 轴突变最大 -> 可能是【后摔】
       * 2. 如果 Y 轴分量突变 -> 可能是【前摔】
       * 3. 如果 X 轴分量突变 -> 可能是【侧摔】
       */

      // 模拟简单的分类逻辑：
      const absX = Math.abs(currentData.x);
      const absY = Math.abs(currentData.y);
      const absZ = Math.abs(currentData.z);

      if (absX > absY && absX > absZ) {
        return FallType.SIDEWAY;
      } else if (currentData.y > 0 && absY > absZ) {
        return FallType.FORWARD;
      } else if (currentData.y < 0 && absY > absZ) {
        return FallType.BACKWARD;
      }

      return FallType.UNKNOWN;
    }

    return FallType.NONE;
  }
}