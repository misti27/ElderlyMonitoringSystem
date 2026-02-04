import { FamilyStore } from '../models/FamilyStore';
import { User, ActivityStatus, LocationData } from 'shared';

@Component
export default struct Monitor {
  @Consume('familyStore') store: FamilyStore;

  // 格式化位置显示
  private getLocationStr(): string {
    const status = this.store.elderlyStatus;
    if (status && status.location && (status.location.latitude !== 0)) {
      return "朝阳公园"; // 实际开发建议接逆地理编码
    }
    return '获取位置中...';
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 背景色
      Column().width('100%').height('100%').backgroundColor('#F8FAFC')

      Scroll() {
        Column({ space: 20 }) {
          // 1. 顶部：老人切换 & 紧急呼叫按钮
          this.buildTopHeader()

          if (this.store.currentElderly) {
            // 2. 实时安危状态（这是子女最关心的：平安还是危险）
            this.buildSafetyStatusCard()

            // 3. 核心健康指标网格（参考图片中的数据排版）
            this.buildVitalGrid()

            // 4. 今日活动趋势（复刻图片里的蓝色曲线图概念）
            this.buildActivityCurve()

            // 5. 设备监控（信号、电量，参考图片中的状态图标）
            this.buildDeviceStatusCard()

          } else {
            this.buildEmptyState()
          }

          Row().height(80) // 底部导航留白
        }
        .padding({ left: 16, right: 16, top: 16 })
      }
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }

  // --- 组件：顶部导航 ---
  @Builder buildTopHeader() {
    Row() {
      // 老人切换按钮
      Row() {
        ForEach(this.store.elderlyList, (item: User) => {
          Text(item.name)
            .fontSize(this.store.currentElderly?.id === item.id ? 18 : 14)
            .fontWeight(this.store.currentElderly?.id === item.id ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.store.currentElderly?.id === item.id ? '#1A1A1A' : '#999')
            .margin({ right: 16 })
            .onClick(() => this.store.switchElderly(item.id))
        })
      }

      Blank()

      // 紧急电话按钮
      Button({ type: ButtonType.Circle }) {
        Text('📞').fontSize(18)
      }
      .width(44).height(44)
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 10, color: '#15000000' })
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  // --- 组件：实时安危状态卡片 ---
  @Builder buildSafetyStatusCard() {
    Column() {
      Row() {
        // 根据状态切换图标颜色
        Stack() {
          Circle({ width: 60, height: 60 })
            .fill(this.store.elderlyStatus?.isFall ? '#FFF1F0' : '#F6FFED')
          Text(this.store.elderlyStatus?.isFall ? '❗' : '🛡️').fontSize(30)
        }

        Column() {
          Text(this.store.elderlyStatus?.isFall ? '监测到疑似跌倒！' : '当前状态：平安')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.store.elderlyStatus?.isFall ? '#FF4D4F' : '#52C41A')

          Text(this.getActivityDesc())
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })

        Blank()

        if (this.store.elderlyStatus?.isFall) {
          Button('立即处理')
            .backgroundColor('#FF4D4F')
            .height(32)
            .fontSize(12)
        }
      }
      .width('100%')
    }
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 20, color: '#08000000', offsetY: 10 })
  }

  // --- 组件：核心健康网格 ---
  @Builder buildVitalGrid() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
      this.buildVitalItem('❤️', '实时心率', `${this.store.elderlyStatus?.heartRate ?? '--'}`, 'bpm', '#FF4D4F')
      this.buildVitalItem('📍', '最近位置', this.getLocationStr(), '', '#1890FF')
    }
  }

  @Builder buildVitalItem(icon: string, label: string, val: string, unit: string, color: string) {
    Column() {
      Row() {
        Text(icon).fontSize(14).margin({ right: 4 })
        Text(label).fontSize(12).fontColor('#999')
      }
      Row() {
        Text(val).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
        Text(unit).fontSize(12).fontColor('#999').margin({ left: 4, top: 6 })
      }.margin({ top: 8 })

      // 底部装饰条，增加精致感
      Rect().width(30).height(3).radius(1.5).fill(color).margin({ top: 12 }).opacity(0.6)
    }
    .width('47%') // 两列布局
    .padding(20)
    .margin({ bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 10, color: '#05000000', offsetY: 5 })
    .alignItems(HorizontalAlign.Start)
  }

  // --- 组件：今日活动趋势（复刻图片中的曲线图风格） ---
  @Builder buildActivityCurve() {
    Column() {
      Row() {
        Text('今日活跃度趋势').fontSize(16).fontWeight(FontWeight.Bold)
        Blank()
        Text('查看轨迹 >').fontSize(12).fontColor('#999')
      }.width('100%').margin({ bottom: 15 })

      Row() {
        Text('08:00').fontSize(10).fontColor('#CCC')
        Text('12:00').fontSize(10).fontColor('#CCC')
        Text('16:00').fontSize(10).fontColor('#CCC')
        Text('20:00').fontSize(10).fontColor('#CCC')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 15, color: '#08000000' })
  }

  // --- 组件：设备状态（子女关心的：设备有没电，信号好不好） ---
  @Builder buildDeviceStatusCard() {
    Row() {
      Column() {
        Text('设备在线').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
        Text('华为 Mate 60 Pro').fontSize(11).fontColor('#999').margin({ top: 4 })
      }.alignItems(HorizontalAlign.Start)

      Blank()

      // 信号强度（参考图片里的绿色信号图标）
      Row() {
        Text('📶').fontSize(12).margin({ right: 4 })
        Text('信号强').fontSize(12).fontColor('#52C41A')
      }.margin({ right: 16 })

      // 电量
      Row() {
        Text('🔋').fontSize(12).margin({ right: 4 })
        Text(`${this.store.elderlyStatus?.batteryLevel ?? 0}%`).fontSize(12).fontColor('#1A1A1A')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#f5f7fa') // 浅蓝色淡雅底色
    .borderRadius(16)
    .border({ width: 1, color: '#D0E7FF' })
  }

  @Builder buildEmptyState() {
    Column() {
      Text('请选择要关注的老人').fontColor('#999').margin({ top: 100 })
    }.width('100%')
  }

  private getActivityDesc(): string {
    const status = this.store.elderlyStatus?.activityStatus;
    switch (status) {
      case ActivityStatus.STILL: return '正在休息，已持续 2 小时';
      case ActivityStatus.WALKING: return '正在户外散步';
      case ActivityStatus.RUNNING: return '正在晨练';
      default: return '状态已离线';
    }
  }
}