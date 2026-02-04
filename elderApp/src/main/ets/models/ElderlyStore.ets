// 1. 修正导入：统一从 shared 导入，并引入必要的模型接口
import {
  ElderlyStatus,
  User,
  ElderlyStatusModel,
  AccelerometerData,
  LocationData
} from 'shared';

/**
 * 老人端全局状态管理
 */
@Observed // 加上观察者装饰器，确保 UI 能响应数据变化
export class ElderlyStore {
  // 用户信息
  user: User = new User();

  // 当前状态
  currentStatus: ElderlyStatus = new ElderlyStatus();

  // 传感器数据缓存：⚠️ 修正 any[] 为明确的 AccelerometerData[]
  sensorDataBuffer: AccelerometerData[] = [];

  // 是否正在采集
  isCollecting: boolean = false;

  // 是否已绑定设备
  isDeviceBound: boolean = false;

  /**
   * 更新用户信息
   */
  updateUser(user: User): void {
    try {
      this.user = user;
      // ⚠️ 修正：ArkTS 推荐显式判断字符串是否为空
      this.isDeviceBound = (user.bindDeviceId !== '');
    } catch (err) {
      console.error('更新用户信息失败');
    }
  }

  /**
   * 更新当前状态
   * ⚠️ 修正：ArkTS 不支持 Partial<T> 和对象展开符 {...this.currentStatus, ...status}
   */
  updateStatus(model: ElderlyStatusModel): void {
    try {
      // 在 ArkTS 中，必须手动赋值来更新属性，或者整体替换实例
      if (model.heartRate !== undefined) {
        this.currentStatus.heartRate = model.heartRate;
      }
      if (model.activityStatus !== undefined) {
        this.currentStatus.activityStatus = model.activityStatus;
      }
      if (model.isFall !== undefined) {
        this.currentStatus.isFall = model.isFall;
      }
      if (model.location !== undefined) {
        this.currentStatus.location = new LocationData(model.location);
      }
      if (model.batteryLevel !== undefined) {
        this.currentStatus.batteryLevel = model.batteryLevel;
      }

      this.currentStatus.timestamp = Date.now();
    } catch (err) {
      console.error('更新状态失败');
    }
  }

  /**
   * 更新紧急联系人电话
   */
  updateEmergencyPhone(phone: string): void {
    try {
      this.user.emergencyPhone = phone;
      console.info('紧急电话已更新: ' + phone);
    } catch (err) {
      console.error('更新紧急电话失败');
    }
  }

  /**
   * 添加传感器数据到缓冲区
   */
  addSensorData(data: AccelerometerData): void {
    try {
      this.sensorDataBuffer.push(data);

      // 限制缓冲区大小
      if (this.sensorDataBuffer.length > 100) {
        this.sensorDataBuffer.shift();
      }
    } catch (err) {
      console.error('添加传感器数据失败');
    }
  }

  /**
   * 清空传感器数据缓冲区
   */
  clearSensorBuffer(): void {
    this.sensorDataBuffer = [];
  }

  /**
   * 开始采集
   */
  startCollecting(): void {
    this.isCollecting = true;
  }

  /**
   * 停止采集
   */
  stopCollecting(): void {
    this.isCollecting = false;
  }

  /**
   * 重置状态
   */
  reset(): void {
    this.user = new User();
    this.currentStatus = new ElderlyStatus();
    this.sensorDataBuffer = [];
    this.isCollecting = false;
    this.isDeviceBound = false;
  }
}

// 创建并导出全局实例
export const elderlyStore = new ElderlyStore();