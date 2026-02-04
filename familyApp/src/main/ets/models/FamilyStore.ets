import { User, ElderlyStatus, Alert, AlertStatus } from 'shared';
/**
 * 子女端全局状态管理
 */
@Observed
export class FamilyStore {
  // 用户信息
  user: User = new User()
  
  // 绑定的老人列表
  elderlyList: User[] = []
  
  // 当前查看的老人
  currentElderly: User | undefined = undefined; // 当前选中的那一个
  
  // 老人实时状态
  elderlyStatus?: ElderlyStatus = undefined
  
  // 历史数据列表
  historyList: ElderlyStatus[] = []
  
  // 报警列表
  alertList: Alert[] = []
  
  // 未读报警数量
  unreadAlertCount: number = 0

  // 绑定的家属手机号
  familyPhone: string = ''

  // 同步频率（秒）
  syncInterval: number = 5

  /**
   * 更新用户信息
   */
  updateUser(user: User): void {
    try {
      this.user = user ?? new User()
    } catch (err) {
      console.error('更新用户信息失败', err)
    }
  }
  
  /**
   * 设置老人列表
   */
  setElderlyList(list: User[]): void {
    try {
      this.elderlyList = list ?? []
      
      // 默认选中第一个
      if (this.elderlyList.length > 0 && !this.currentElderly) {
        this.currentElderly = this.elderlyList[0]
      }
    } catch (err) {
      console.error('设置老人列表失败', err)
    }
  }
  
  /**
   * 切换当前查看的老人
   */
  switchElderly(id: string): void {
    const target = this.elderlyList.find(e => e.id === id);
    if (target) {
      this.currentElderly = target;
      // 当切换老人时，你应该清空旧老人的实时状态，重新去后端取新老人的数据
      console.info('切换老人为: ' + target.name);
    }
  }
  
  /**
   * 更新老人状态
   */
  updateElderlyStatus(status: ElderlyStatus): void {
    try {
      this.elderlyStatus = status ?? undefined
    } catch (err) {
      console.error('更新老人状态失败', err)
    }
  }
  
  /**
   * 设置历史数据列表
   */
  setHistoryList(list: ElderlyStatus[]): void {
    try {
      this.historyList = list ?? []
    } catch (err) {
      console.error('设置历史数据失败', err)
    }
  }
  
  /**
   * 添加历史数据
   */
  appendHistoryList(list: ElderlyStatus[]): void {
    try {
      this.historyList = [...this.historyList, ...(list ?? [])]
    } catch (err) {
      console.error('添加历史数据失败', err)
    }
  }
  
  /**
   * 设置报警列表
   */
  setAlertList(list: Alert[]): void {
    try {
      this.alertList = list ?? []
      this.updateUnreadCount()
    } catch (err) {
      console.error('设置报警列表失败', err)
    }
  }
  
  /**
   * 添加新报警
   */
  addAlert(alert: Alert): void {
    try {
      this.alertList = [alert, ...this.alertList]
      this.updateUnreadCount()
    } catch (err) {
      console.error('添加报警失败', err)
    }
  }
  
  /**
   * 更新报警状态
   */
  updateAlert(alertId: string, status: AlertStatus): void {
    try {
      const index = this.alertList.findIndex(a => a.id === alertId)
      if (index !== -1) {
        this.alertList[index].status = status
        if (status === AlertStatus.CONFIRMED) {
          this.alertList[index].confirmedAt = Date.now()
        } else if (status === AlertStatus.RESOLVED) {
          this.alertList[index].resolvedAt = Date.now()
        }
        this.updateUnreadCount()
      }
    } catch (err) {
      console.error('更新报警状态失败', err)
    }
  }
  
  /**
   * 更新未读报警数量
   */
  private updateUnreadCount(): void {
    try {
      this.unreadAlertCount = this.alertList.filter(
        a => a.status === AlertStatus.PENDING
      ).length
    } catch (err) {
      console.error('更新未读数量失败', err)
      this.unreadAlertCount = 0
    }
  }

  /**
   * 更新家属手机号
   */
  updateFamilyPhone(phone: string): void {
    try {
      this.familyPhone = phone
      console.info('家属手机号已更新: ' + phone)
    } catch (err) {
      console.error('更新家属手机号失败', err)
    }
  }

  /**
   * 更新同步频率
   */
  updateSyncInterval(interval: number): void {
    try {
      if (interval > 0) {
        this.syncInterval = interval
        console.info('同步频率已更新: 每 ' + interval + ' 秒')
      }
    } catch (err) {
      console.error('更新同步频率失败', err)
    }
  }

  /**
   * 重置状态
   */
  reset(): void {
    try {
      this.user = new User()
      this.elderlyList = []
      this.currentElderly = undefined
      this.elderlyStatus = undefined
      this.historyList = []
      this.alertList = []
      this.unreadAlertCount = 0
      this.familyPhone = ''
      this.syncInterval = 5
    } catch (err) {
      console.error('重置状态失败', err)
    }
  }
}

// 创建全局实例
export const familyStore = new FamilyStore()
