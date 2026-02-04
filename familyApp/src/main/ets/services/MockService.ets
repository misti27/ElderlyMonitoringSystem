import { User, ElderlyStatus, ActivityStatus, Alert, AlertStatus } from 'shared';
import { familyStore } from '../models/FamilyStore';

export class MockService {
  static initMockData() {
    // 1. 家属信息
    familyStore.user = new User({ id: 'f1', name: '王小明' });

    // 2. 老人信息
    const mockElderly = new User({ id: 'e1', name: '张大爷' });
    familyStore.elderlyList = [mockElderly];
    familyStore.currentElderly = mockElderly;

    // 3. 实时状态 (⚠️ 使用 new 实例化)
    familyStore.elderlyStatus = new ElderlyStatus({
      heartRate: 75,
      batteryLevel: 80,
      activityStatus: ActivityStatus.WALKING,
      location: { latitude: 39.9, longitude: 116.4 }
    });

    // 4. 报警列表 (⚠️ 使用 new 实例化)
    familyStore.alertList = [
      new Alert({ id: 'a1', content: '心率偏高提醒', status: AlertStatus.PENDING })
    ];

    // 5. 历史记录 (⚠️ 数组里的每一项都要 new)
    familyStore.historyList = [
      new ElderlyStatus({ heartRate: 72, activityStatus: ActivityStatus.STILL, timestamp: Date.now() - 3600000 }),
      new ElderlyStatus({ heartRate: 85, activityStatus: ActivityStatus.WALKING, timestamp: Date.now() - 7200000 }),
      new ElderlyStatus({ heartRate: 68, activityStatus: ActivityStatus.STILL, timestamp: Date.now() - 10800000 })
    ];

    familyStore.unreadAlertCount = 1;
  }
}