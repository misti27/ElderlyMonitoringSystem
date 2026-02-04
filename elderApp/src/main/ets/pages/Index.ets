import router from '@ohos.router';
import { ElderlyStore, elderlyStore } from '../models/ElderlyStore';
import { ActivityStatus, TimeUtil } from 'shared';

@Entry
@Component
struct Index {
  @State store: ElderlyStore = elderlyStore;
  @State isRunning: boolean = true;

  // 统一定义配置
  private readonly TitleSize: number = 24;
  private readonly LabelSize: number = 18;
  private readonly ValueSize: number = 24; // 稍微调大一点，更有视觉冲击力
  private readonly HeartRateLimit: number = 100; // 心率报警上限

  // 1. 计算心率颜色的逻辑
  private getHeartRateColor(): string {
    const hr = this.store.currentStatus.heartRate ?? 0;
    if (hr > this.HeartRateLimit) {
      return '#D0021B'; // 超过限值显示红色
    }
    return '#07C160'; // 正常显示绿色
  }

  // 2. 计算电量颜色的逻辑
  private getBatteryColor(): string {
    const battery = this.store.currentStatus.batteryLevel ?? 0;
    if (battery > 60) {
      return '#07C160'; // 高于60绿色
    }
    if (battery >= 20) {
      return '#FA8C16'; // 20-60橙色
    }
    return '#D0021B'; // 20以下红色
  }

  build() {
    Column() {
      // 1. 顶部状态栏
      Row() {
        Column() {
          Text('健康状态：正常')
            .fontSize(this.TitleSize)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111')
          Text('数据每 10 秒自动同步')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)

        Blank()

        Image($r('app.media.icon_setting'))
          .width(28).height(28)
          .onClick(() => router.pushUrl({ url: 'pages/Settings' }))
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 40, bottom: 24 })
      .backgroundColor('#FFF')

      // 2. 核心指标列表
      List({ space: 12 }) {
        ListItem() {
          // 传入计算出的颜色
          this.buildMetricRow('❤️ 实时心率', `${this.store.currentStatus.heartRate ?? '--'}`, '次/分', this.getHeartRateColor())
        }
        ListItem() {
          this.buildMetricRow('🚶 当前状态', this.getActivityStatusText(), '', '#111')
        }
        ListItem() {
          // 传入计算出的颜色，并读取真实电量
          this.buildMetricRow('🔋 设备电量', `${this.store.currentStatus.batteryLevel ?? '--'}`, '%', this.getBatteryColor())
        }
        ListItem() {
          this.buildMetricRow('📍 最近位置', '家附近', '', '#111')
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)

      // 3. 底部紧急操作区
      Column() {
        Button('紧急求助 (SOS)')
          .width('100%')
          .height(72)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#D0021B')
          .borderRadius(16)
          .onClick(() => router.pushUrl({ url: 'pages/Emergency' }))
      }
      .padding(20)
      .backgroundColor('#FFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7Fa')
  }

  // ⚠️ 3. 修改了参数，增加了 valueColor
  @Builder buildMetricRow(label: string, value: string, unit: string, valueColor: string) {
    Row() {
      Text(label)
        .fontSize(this.LabelSize)
        .fontColor('#444')

      Blank()

      Row() {
        Text(value)
          .fontSize(this.ValueSize)
          .fontWeight(FontWeight.Bold) // 加粗数值，更易读
          .fontColor(valueColor) // 使用动态颜色
        if (unit) {
          Text(unit)
            .fontSize(14)
            .fontColor('#999')
            .margin({ left: 4, top: 6 })
        }
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  private getActivityStatusText(): string {
    const status = this.store.currentStatus.activityStatus ?? ActivityStatus.UNKNOWN;
    switch (status) {
      case ActivityStatus.STILL: return '静止';
      case ActivityStatus.WALKING: return '行走';
      case ActivityStatus.RUNNING: return '跑步';
      default: return '未知';
    }
  }
}