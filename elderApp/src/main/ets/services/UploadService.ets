import { HttpUtil, Constants, ActivityStatus, LocationModel } from 'shared';
import { elderlyStore } from '../models/ElderlyStore';
import { BusinessError } from '@ohos.base';

/**
 * 1. 定义上传参数接口
 */
interface StatusUploadParams {
  userId: string;
  deviceId: string;
  activityStatus: ActivityStatus;
  heartRate: number;
  location: LocationModel;
  isFall: boolean;
  timestamp: number;
}

interface AlertReportParams {
  userId: string;
  deviceId: string;
  type: string;
  message: string;
  location: LocationModel;
  timestamp: number;
}

/**
 * 数据上传服务
 */
export class UploadService {
  private static instance: UploadService;

  private uploadTimer: number = -1;
  private isUploading: boolean = false;

  private constructor() {}

  static getInstance(): UploadService {
    if (!UploadService.instance) {
      UploadService.instance = new UploadService();
    }
    return UploadService.instance;
  }

  startAutoUpload(): void {
    try {
      if (this.uploadTimer !== -1) {
        clearInterval(this.uploadTimer);
      }

      this.uploadTimer = setInterval(() => {
        // 在定时器中调用异步方法，ArkTS 建议不直接在回调写 async
        this.uploadStatus();
      }, Constants.SENSOR.UPLOAD_INTERVAL);

      console.info('自动上传已启动');
    } catch (err) {
      console.error('启动自动上传失败');
    }
  }

  stopAutoUpload(): void {
    if (this.uploadTimer !== -1) {
      clearInterval(this.uploadTimer);
      this.uploadTimer = -1;
    }
    console.info('自动上传已停止');
  }

  /**
   * 上传状态数据
   */
  async uploadStatus(): Promise<boolean> {
    if (this.isUploading) {
      return false;
    }

    try {
      this.isUploading = true;
      const status = elderlyStore.currentStatus;

      // 检查数据有效性：ArkTS 要求显式判断空字符串
      if (status.userId === '') {
        console.warn('用户ID不存在，跳过上传');
        return false;
      }

      // 2. 构造符合接口要求的对象变量
      const params: StatusUploadParams = {
        userId: status.userId,
        deviceId: status.deviceId,
        activityStatus: status.activityStatus,
        heartRate: status.heartRate,
        location: {
          latitude: status.location.latitude,
          longitude: status.location.longitude,
          accuracy: status.location.accuracy
        } as LocationModel,
        isFall: status.isFall,
        timestamp: status.timestamp
      };

      // 3. 显式指定泛型参数 <Object> 并使用类型断言 as Object
      const response = await HttpUtil.post<Object>(Constants.API.UPLOAD_STATUS, params as Object);

      if (response.code === 200) {
        console.info('状态上传成功');
        elderlyStore.clearSensorBuffer();
        return true;
      } else {
        console.error('状态上传失败: ' + response.message);
        return false;
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error('上传状态数据异常: ' + error.message);
      return false;
    } finally {
      this.isUploading = false;
    }
  }

  /**
   * 上报异常事件
   */
  async reportAlert(type: string, message: string): Promise<boolean> {
    try {
      const status = elderlyStore.currentStatus;

      // 4. 同样使用接口构造对象
      const params: AlertReportParams = {
        userId: status.userId,
        deviceId: status.deviceId,
        type: type,
        message: message,
        location: {
          latitude: status.location.latitude,
          longitude: status.location.longitude
        } as LocationModel,
        timestamp: Date.now()
      };

      const response = await HttpUtil.post<Object>('/alert/report', params as Object);

      if (response.code === 200) {
        console.info('异常事件上报成功');
        return true;
      } else {
        console.error('异常事件上报失败: ' + response.message);
        return false;
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error('上报异常事件异常: ' + error.message);
      return false;
    }
  }
}