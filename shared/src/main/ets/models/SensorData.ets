/**
 * 加速度数据初始化接口
 */
export interface AccelerometerModel {
  x?: number;
  y?: number;
  z?: number;
  timestamp?: number;
}

/**
 * 加速度数据
 */
export class AccelerometerData {
  x: number = 0;
  y: number = 0;
  z: number = 0;
  timestamp: number = 0;

  constructor(data?: AccelerometerModel) {
    if (data) {
      this.x = data.x ?? 0;
      this.y = data.y ?? 0;
      this.z = data.z ?? 0;
      this.timestamp = data.timestamp ?? Date.now();
    }
  }
}

/**
 * 位置数据初始化接口
 */
export interface LocationModel {
  latitude?: number;
  longitude?: number;
  accuracy?: number;
  timestamp?: number;
  address?: string;
}

/**
 * 位置数据
 */
export class LocationData {
  latitude: number = 0;
  longitude: number = 0;
  accuracy: number = 0;
  timestamp: number = 0;
  address: string = '';

  constructor(data?: LocationModel) {
    if (data) {
      this.latitude = data.latitude ?? 0;
      this.longitude = data.longitude ?? 0;
      this.accuracy = data.accuracy ?? 0;
      this.timestamp = data.timestamp ?? Date.now();
      this.address = data.address ?? '';
    }
  }
}

/**
 * 运动状态枚举
 */
export enum ActivityStatus {
  STILL = 'still',      // 静止
  WALKING = 'walking',  // 行走
  RUNNING = 'running',  // 跑步
  UNKNOWN = 'unknown'   // 未知
}

/**
 * 跌倒类型枚举
 */
export enum FallType {
  NONE = 0,     // 未跌倒
  FORWARD = 1,  // 前摔
  BACKWARD = 2, // 后摔
  SIDEWAY = 3,  // 侧摔
  UNKNOWN = 4   // 未知跌倒
}

/**
 * 老人状态数据初始化接口
 */
export interface ElderlyStatusModel {
  userId?: string;
  deviceId?: string;
  activityStatus?: ActivityStatus;
  heartRate?: number;
  location?: LocationModel;
  isFall?: boolean;
  fallType?: FallType;
  timestamp?: number;
  batteryLevel?: number;
}

/**
 * 老人状态数据
 */
export class ElderlyStatus {
  userId: string = '';
  deviceId: string = '';
  activityStatus: ActivityStatus = ActivityStatus.UNKNOWN;
  heartRate: number = 0;
  location: LocationData = new LocationData();
  isFall: boolean = false;
  fallType: FallType = FallType.NONE;
  timestamp: number = 0;
  batteryLevel: number = 0;

  constructor(data?: ElderlyStatusModel) {
    if (data) {
      this.userId = data.userId ?? '';
      this.deviceId = data.deviceId ?? '';
      this.activityStatus = data.activityStatus ?? ActivityStatus.UNKNOWN;
      this.heartRate = data.heartRate ?? 0;
      this.location = data.location ? new LocationData(data.location) : new LocationData();
      this.isFall = data.isFall ?? false;
      this.fallType = data.fallType ?? FallType.NONE;
      this.timestamp = data.timestamp ?? Date.now();
      this.batteryLevel = data.batteryLevel ?? 0;
    }
  }
}