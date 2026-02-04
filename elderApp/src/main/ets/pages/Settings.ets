import router from '@ohos.router';

@Entry
@Component
struct Settings {
  @State familyPhone: string = '138****8888';
  @State fallSensitivity: number = 70;

  build() {
    Column() {
      // 1. 自定义标题栏
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor('#007DFF')
          .onClick(() => router.back())
        Blank()
        Text('个人设置').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text('保存').fontSize(16).fontColor('#007DFF')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFF')

      Scroll() {
        Column({ space: 20 }) {
          // 2. 账号与家属绑定卡片
          this.buildSectionTitle('连接与绑定')
          Column() {
            this.buildSettingItem('绑定家属手机', this.familyPhone, () => {
              // 弹出输入框逻辑
            })
            Divider().margin({ left: 16, right: 16 })
            this.buildSettingItem('同步频率', '每 5 秒', () => {})
          }
          .backgroundColor('#FFF')
          .borderRadius(16)

          // 3. 算法灵敏度设置 (图片中的仪表盘数值概念)
          this.buildSectionTitle('安全监测配置')
          Column() {
            Row() {
              Text('跌倒检测灵敏度').fontSize(14).fontColor('#333')
              Blank()
              Text(this.fallSensitivity.toString() + '%').fontSize(14).fontColor('#007DFF')
            }.width('100%').padding(16)

            Slider({
              value: this.fallSensitivity,
              min: 0,
              max: 100,
              style: SliderStyle.InSet
            })
              .width('90%')
              .blockColor('#007DFF')
              .trackColor('#F0F0F0')
              .selectedColor('#007DFF')
              .onChange((v) => this.fallSensitivity = Math.floor(v))
              .margin({ bottom: 16 })
          }
          .backgroundColor('#FFF')
          .borderRadius(16)

          // 4. 关于与退出
          Button('退出当前账号')
            .width('100%')
            .height(50)
            .backgroundColor('#FFF')
            .fontColor('#FF4D4F')
            .borderRadius(16)
            .margin({ top: 20 })

        }
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  buildSectionTitle(text: string) {
    Text(text)
      .fontSize(14)
      .fontColor('#999')
      .margin({ left: 4, bottom: -8 })
      .alignSelf(ItemAlign.Start)
  }

  @Builder
  buildSettingItem(label: string, value: string, onClick: () => void) {
    Row() {
      Text(label).fontSize(14).fontColor('#333')
      Blank()
      Text(value).fontSize(14).fontColor('#999').margin({ right: 8 })
      Text(' > ').fontSize(14).fontColor('#CCC')
    }
    .width('100%')
    .height(56)
    .padding(16)
    .onClick(onClick)
  }
}