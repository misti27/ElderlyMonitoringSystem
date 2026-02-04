import webSocket from '@ohos.net.webSocket';
import { BusinessError } from '@ohos.base';
// 1. 修正导入：统一从 shared 导入模型和接口
import {
  Constants,
  ElderlyStatus,
  ElderlyStatusModel,
  Alert,
  AlertModel
} from 'shared';
import { familyStore } from '../models/FamilyStore';

/**
 * 定义 WebSocket 消息体接口，解决 any 问题
 */
interface WsMessage {
  type: string;
  data: Object;
}

/**
 * WebSocket服务
 */
export class WebSocketService {
  private static instance: WebSocketService | undefined = undefined;

  private ws: webSocket.WebSocket | undefined = undefined;
  private isConnected: boolean = false;
  private reconnectTimer: number = -1;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;

  // 事件回调
  private onStatusUpdate: ((status: ElderlyStatus) => void) | undefined = undefined;
  private onAlert: ((alert: Alert) => void) | undefined = undefined;

  private constructor() {}

  /**
   * 获取单例
   */
  static getInstance(): WebSocketService {
    if (!WebSocketService.instance) {
      WebSocketService.instance = new WebSocketService();
    }
    return WebSocketService.instance;
  }

  /**
   * 连接WebSocket
   */
  async connect(token: string): Promise<void> {
    try {
      if (this.isConnected) {
        console.info('WebSocket已连接');
        return;
      }

      // 创建WebSocket实例
      this.ws = webSocket.createWebSocket();

      // 设置事件监听 (必须在 connect 之前或之后立即设置)
      this.setupEventListeners(token);

      // 连接服务器
      const url = Constants.WS_BASE_URL + '?token=' + token;
      await this.ws.connect(url);

      this.isConnected = true;
      this.reconnectAttempts = 0;
      console.info('WebSocket连接指令已发送');
    } catch (err) {
      const error = err as BusinessError;
      console.error('WebSocket连接失败: ' + error.message);
      this.scheduleReconnect(token);
    }
  }

  /**
   * 断开连接
   */
  disconnect(): void {
    try {
      if (this.ws && this.isConnected) {
        this.ws.close();
        this.ws = undefined;
        this.isConnected = false;

        if (this.reconnectTimer !== -1) {
          clearTimeout(this.reconnectTimer);
          this.reconnectTimer = -1;
        }
        console.info('WebSocket已断开');
      }
    } catch (err) {
      console.error('断开WebSocket失败');
    }
  }

  /**
   * 设置事件监听器
   */
  private setupEventListeners(token: string): void {
    if (!this.ws) return;

    // 1. 连接打开
    this.ws.on('open', (err: BusinessError, value: Object) => {
      if (!err) {
        console.info('WebSocket连接成功');
        this.isConnected = true;
      }
    });

    // 2. 消息接收 (⚠️ ArkTS 要求明确参数类型)
    this.ws.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
      if (err) {
        console.error('接收消息失败');
        return;
      }

      try {
        const messageString = typeof value === 'string' ? value : '';
        if (messageString !== '') {
          const message = JSON.parse(messageString) as WsMessage;
          this.handleMessage(message);
        }
      } catch (parseErr) {
        console.error('解析消息失败');
      }
    });

    // 3. 连接关闭
    this.ws.on('close', (err: BusinessError, value: webSocket.CloseResult) => {
      if (err) {
        console.error('WebSocket关闭异常: ' + err.message);
      }
      console.info('WebSocket连接已关闭, 原因: ' + value.reason + ' 状态码: ' + value.code.toString());
      this.isConnected = false;
      this.scheduleReconnect(token);
    });

    // 4. 错误处理
    this.ws.on('error', (err: BusinessError) => {
      console.error('WebSocket错误: ' + err.message);
      this.isConnected = false;
    });
  }

  /**
   * 处理接收到的消息
   */
  private handleMessage(message: WsMessage): void {
    try {
      const type = message.type;

      if (type === 'status_update') {
        // 状态更新：将 data 强制转换为 ElderlyStatusModel 接口
        const statusData = message.data as ElderlyStatusModel;
        const status = new ElderlyStatus(statusData);
        familyStore.updateElderlyStatus(status);
        if (this.onStatusUpdate) {
          this.onStatusUpdate(status);
        }
      } else if (type === 'alert') {
        // 新报警：将 data 强制转换为 AlertModel 接口
        const alertData = message.data as AlertModel;
        const alert = new Alert(alertData);
        familyStore.addAlert(alert);
        if (this.onAlert) {
          this.onAlert(alert);
        }
      } else {
        console.warn('未知消息类型: ' + type);
      }
    } catch (err) {
      console.error('处理消息失败');
    }
  }

  /**
   * 安排重连
   */
  private scheduleReconnect(token: string): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('重连次数已达上限');
      return;
    }

    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);

    this.reconnectTimer = setTimeout(() => {
      this.reconnectAttempts++;
      console.info('尝试重连...');
      this.connect(token);
    }, delay);
  }

  /**
   * 设置状态更新回调
   */
  setOnStatusUpdate(callback: (status: ElderlyStatus) => void): void {
    this.onStatusUpdate = callback;
  }

  /**
   * 设置报警回调
   */
  setOnAlert(callback: (alert: Alert) => void): void {
    this.onAlert = callback;
  }

  /**
   * 发送消息
   * ⚠️ data 使用 Object 代替 any
   */
  send(data: Object): void {
    try {
      if (this.ws && this.isConnected) {
        this.ws.send(JSON.stringify(data));
      } else {
        console.warn('WebSocket未连接');
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error('发送消息失败: ' + error.message);
    }
  }
}