import { FamilyStore } from '../models/FamilyStore';

@Component
export default struct Device {
  @Consume('familyStore') store: FamilyStore;

  build() {
    Column() {
      // 1. 顶部设备状态卡片
      this.buildDeviceHeader()

      Scroll() {
        Column({ space: 16 }) {
          // 2. 核心状态面板
          this.buildStatusPanel()

          // 3. 设备参数设置组
          this.buildSettingsGroup()

          // 4. 危险操作区
          Button('解除设备绑定')
            .width('100%')
            .height(50)
            .backgroundColor('#fff1f0')
            .fontColor('#ff4d4f')
            .borderRadius(12)
            .margin({ top: 20, bottom: 40 })
            .onClick(() => {
              // 处理解绑逻辑
            })
        }
        .padding(16)
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f7fa')
  }

  // 顶部大卡片：展示设备型号和实时连接状态
  @Builder
  buildDeviceHeader() {
    Column() {
      Row() {
        // 设备图标
        Stack() {
          Circle({ width: 70, height: 70 }).fill('#ffffff').opacity(0.2)
          Text('📱').fontSize(40)
        }
        .margin({ right: 20 })

        Column() {
          Text('老年人健康监测')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')

          Row() {
            // 状态指示灯
            Circle({ width: 8, height: 8 })
              .fill('#52c41a')
              .margin({ right: 6 })
            Text('已连接')
              .fontSize(14)
              .fontColor('#ffffff')
              .opacity(0.9)
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 40, bottom: 40 })
    }
    .width('100%')
    .backgroundColor('#1890ff')
  }

  // 状态面板：展示电量、序列号等
  @Builder
  buildStatusPanel() {
    Row() {
      this.buildStatusItem('剩余电量', `${this.store.elderlyStatus?.batteryLevel ?? 0}%`, '#52c41a')
      Divider().vertical(true).height(30).color('#eee')
      this.buildStatusItem('信号强度', '极强', '#1890ff')
      Divider().vertical(true).height(30).color('#eee')
      this.buildStatusItem('固件版本', 'v1.2.4', '#999')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#ffffff')
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceAround)
    .shadow({ radius: 10, color: '#10000000', offsetX: 0, offsetY: 5 })
  }

  @Builder
  buildStatusItem(label: string, value: string, color: string) {
    Column() {
      Text(label).fontSize(12).fontColor('#999').margin({ bottom: 4 })
      Text(value).fontSize(16).fontWeight(FontWeight.Bold).fontColor(color)
    }
  }

  // 设置组：报警阈值等配置
  @Builder
  buildSettingsGroup() {
    Column() {
      Text('设备配置')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12, left: 4 })
        .alignSelf(ItemAlign.Start)

      Column() {
        this.buildMenuRow('心率报警上限', '120 bpm')
        this.buildMenuRow('采样频率', '每10秒一次')
        this.buildMenuRow('跌倒检测灵敏度', '中等')
        this.buildMenuRow('佩戴检测', '已开启', false)
      }
      .backgroundColor('#ffffff')
      .borderRadius(16)
    }
    .width('100%')
  }

  @Builder
  buildMenuRow(title: string, value: string, hasDivider: boolean = true) {
    Column() {
      Row() {
        Text(title).fontSize(15).fontColor('#333')
        Blank()
        Text(value).fontSize(14).fontColor('#999').margin({ right: 8 })
        Text('>').fontSize(14).fontColor('#ccc')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      if (hasDivider) {
        Divider().color('#f5f5f5').margin({ left: 16, right: 16 })
      }
    }
  }
}