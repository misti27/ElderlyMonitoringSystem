/**
 * 接口定义：解决 arkts-no-untyped-obj-literals 报错
 */
export interface ApiConfig {
  LOGIN: string;
  REGISTER: string;
  USER_INFO: string;
  BIND_DEVICE: string;
  DEVICE_STATUS: string;
  UPLOAD_STATUS: string;
  GET_STATUS: string;
  GET_HISTORY: string;
  GET_ALERTS: string;
  CONFIRM_ALERT: string;
  RESOLVE_ALERT: string;
}

export interface StorageConfig {
  TOKEN: string;
  USER_INFO: string;
  DEVICE_ID: string;
}

export interface SensorConfig {
  SAMPLE_INTERVAL: number;
  UPLOAD_INTERVAL: number;
  FALL_THRESHOLD: number;
  STILL_THRESHOLD: number;
}

/**
 * 应用常量配置
 */
export class Constants {
  // 基础URL配置
  static readonly API_BASE_URL: string = 'http://192.168.1.100:8080/api';
  static readonly WS_BASE_URL: string = 'ws://192.168.1.100:8080/ws';

  // API端点
  // ⚠️修正点：显式指定接口类型 ApiConfig
  static readonly API: ApiConfig = {
    LOGIN: '/user/login',
    REGISTER: '/user/register',
    USER_INFO: '/user/info',
    BIND_DEVICE: '/device/bind',
    DEVICE_STATUS: '/device/status',
    UPLOAD_STATUS: '/status/upload',
    GET_STATUS: '/status/get',
    GET_HISTORY: '/status/history',
    GET_ALERTS: '/alert/list',
    CONFIRM_ALERT: '/alert/confirm',
    RESOLVE_ALERT: '/alert/resolve'
  };

  // 本地存储key
  // ⚠️修正点：显式指定接口类型 StorageConfig
  static readonly STORAGE: StorageConfig = {
    TOKEN: 'token',
    USER_INFO: 'user_info',
    DEVICE_ID: 'device_id'
  };

  // 传感器配置
  // ⚠️修正点：显式指定接口类型 SensorConfig
  static readonly SENSOR: SensorConfig = {
    SAMPLE_INTERVAL: 100,
    UPLOAD_INTERVAL: 5000,
    FALL_THRESHOLD: 2.5,
    STILL_THRESHOLD: 0.2
  };

  // 基础类型也必须显式加上类型标注
  static readonly DATE_FORMAT: string = 'YYYY-MM-DD HH:mm:ss';
  static readonly PAGE_SIZE: number = 20;
}