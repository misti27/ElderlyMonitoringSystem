import { FamilyStore } from '../models/FamilyStore';
import promptAction from '@ohos.promptAction';

// 1. 定义设备配置的数据结构
interface DeviceConfig {
  hrLimit: string;
  sampleRate: string;
  fallSensitivity: string;
  wearDetection: string;
}

@Component
export default struct Device {
  @Consume('familyStore') store: FamilyStore;

  // 2. 将数据存储在对象结构中
  @State config: DeviceConfig = {
    hrLimit: '120 bpm',
    sampleRate: '每10秒一次',
    fallSensitivity: '中等',
    wearDetection: '已开启'
  };

  build() {
    Column() {
      this.buildDeviceHeader()

      Scroll() {
        Column({ space: 16 }) {
          this.buildStatusPanel()

          Column() {
            Text('设备远程配置')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12, left: 4 })
              .alignSelf(ItemAlign.Start)

            Column() {
              // 传入 config 对象中的具体属性
              this.buildMenuRow('心率报警上限', this.config.hrLimit, true, () => {
                this.handleSelect('hrLimit', '设置心率上限', ['100 bpm', '120 bpm', '140 bpm']);
              })

              this.buildMenuRow('采样频率', this.config.sampleRate, true, () => {
                this.handleSelect('sampleRate', '选择采样频率', ['每1秒一次', '每10秒一次', '每30秒一次']);
              })

              this.buildMenuRow('跌倒检测灵敏度', this.config.fallSensitivity, true, () => {
                this.handleSelect('fallSensitivity', '设置灵敏度', ['高', '中等', '低']);
              })

              this.buildMenuRow('佩戴检测', this.config.wearDetection, false, () => {
                // 开关逻辑直接切换
                this.config.wearDetection = this.config.wearDetection === '已开启' ? '已关闭' : '已开启';
              })
            }
            .backgroundColor('#ffffff')
            .borderRadius(16)
          }
          .width('100%')

          Button('同步到老人手机')
            .width('100%')
            .height(50)
            .margin({ top: 10, bottom: 40 })
            .onClick(() => {
              // 这里可以把 this.config 这个数据结构发送给后端
              console.info('当前存储的数据结构: ' + JSON.stringify(this.config));
              promptAction.showToast({ message: '同步成功' });
            })
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f7fa')
  }

  // --- 抽取的通用选择处理函数，解决“没反应”的问题 ---
  private handleSelect(key: string, title: string, options: string[]) {
    promptAction.showActionMenu({
      title: title,
      buttons: [
        { text: options[0], color: '#333' },
        { text: options[1], color: '#333' },
        { text: options[2], color: '#333' }
      ]
    }).then(result => {
      // 关键：判断索引，确保存储到数据结构中
      if (result.index >= 0) {
        const newValue = options[result.index];
        // 动态更新对象属性，触发 UI 刷新
        if (key === 'hrLimit') this.config.hrLimit = newValue;
        if (key === 'sampleRate') this.config.sampleRate = newValue;
        if (key === 'fallSensitivity') this.config.fallSensitivity = newValue;

        promptAction.showToast({ message: `已设为: ${newValue}` });
      }
    }).catch((err: BusinessError) => {
      console.error("err:" + err);
    })
  }

  // --- 保持原版高级感 UI 不变 ---

  @Builder buildDeviceHeader() {
    Column() {
      Row() {
        Stack() {
          Circle({ width: 70, height: 70 }).fill('#ffffff').opacity(0.2)
          Text('📱').fontSize(34)
        }.margin({ right: 20 })
        Column() {
          Text('我的智能设备').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#ffffff')
          Text('在线').fontSize(14).fontColor('#ffffff').opacity(0.9).margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)
      }.width('100%').padding({ left: 24, right: 24, top: 40, bottom: 40 })
    }.width('100%').backgroundColor('#1890ff')
  }

  @Builder buildStatusPanel() {
    Row() {
      this.buildStatusItem('电量', `${this.store.elderlyStatus?.batteryLevel ?? '--'}%`, '#52c41a')
      this.buildStatusItem('信号', '良好', '#1890ff')
      this.buildStatusItem('版本', 'v1.0.2', '#999')
    }
    .width('100%').padding(20).backgroundColor('#ffffff').borderRadius(16).justifyContent(FlexAlign.SpaceAround)
  }

  @Builder buildStatusItem(label: string, value: string, color: string) {
    Column() {
      Text(label).fontSize(12).fontColor('#999').margin({ bottom: 4 })
      Text(value).fontSize(16).fontWeight(FontWeight.Bold).fontColor(color)
    }
  }

  @Builder buildMenuRow(title: string, value: string, hasDivider: boolean, onClick: () => void) {
    Column() {
      Row() {
        Text(title).fontSize(15).fontColor('#333')
        Blank()
        Text(value).fontSize(14).fontColor('#1890ff').margin({ right: 8 })
        Text('>').fontSize(14).fontColor('#ccc')
      }
      .width('100%').height(64).padding({ left: 16, right: 16 })
      .onClick(onClick)

      if (hasDivider) {
        Divider().color('#f5f5f5').margin({ left: 16, right: 16 })
      }
    }
  }
}