// shared/src/main/ets/models/Alert.ets

export enum AlertStatus {
  PENDING = 0,   // 待处理
  CONFIRMED = 1, // 已确认
  RESOLVED = 2   // 已解决
}

export interface AlertModel {
  id?: string;
  type?: string;
  content?: string;
  timestamp?: number;
  status?: AlertStatus;
  confirmedAt?: number;
  resolvedAt?: number;
}

export class Alert {
  id: string = '';
  type: string = '';
  content: string = '';
  timestamp: number = 0;
  status: AlertStatus = AlertStatus.PENDING;
  confirmedAt?: number = undefined;
  resolvedAt?: number = undefined;

  constructor(model?: AlertModel) {
    if (model) {
      this.id = model.id ?? '';
      this.type = model.type ?? '';
      this.content = model.content ?? '';
      this.timestamp = model.timestamp ?? Date.now();
      this.status = model.status ?? AlertStatus.PENDING;
      this.confirmedAt = model.confirmedAt;
      this.resolvedAt = model.resolvedAt;
    }
  }
}