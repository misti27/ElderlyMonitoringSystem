// 1. 修正导入：直接从 shared 导入，避免长路径报错
import { ElderlyStatus, ActivityStatus } from 'shared';

@Component
export default struct StatusPanel {
  // 2. 修正：显式声明类型并给初始值
  @Prop status: ElderlyStatus | undefined = undefined;

  build() {
    Column() {
      Text('当前状态')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Column() {
        // 运动状态
        this.buildStatusRow('运动状态', this.getActivityText(), this.getActivityColor())

        Divider().margin({ top: 12, bottom: 12 })

        // 跌倒状态
        this.buildStatusRow('跌倒检测',
          this.status?.isFall ? '已跌倒' : '正常',
          this.status?.isFall ? '#ff4d4f' : '#52c41a')

        Divider().margin({ top: 12, bottom: 12 })

        // 心率
        this.buildStatusRow('心率',
          `${this.status?.heartRate ?? '--'} bpm`,
          '#1890ff')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#fff')
      .borderRadius(8)
    }
    .width('100%')
    .margin({ top: 16 })
  }

  /**
   * 状态行
   */
  @Builder
  buildStatusRow(label: string, value: string, color: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666')

      Blank()

      Row() {
        Circle()
          .width(8)
          .height(8)
          .fill(color)
          .margin({ right: 8 })

        Text(value)
          .fontSize(14)
          .fontColor(color)
          .fontWeight(FontWeight.Medium)
      }
    }
    .width('100%')
  }

  /**
   * 修正点：获取运动状态文本
   * ⚠️ ArkTS 禁止使用 Record 配合 [enum] 的写法，必须改用 switch-case
   */
  private getActivityText(): string {
    const actStatus: ActivityStatus = this.status?.activityStatus ?? ActivityStatus.UNKNOWN;

    switch (actStatus) {
      case ActivityStatus.STILL:
        return '静止';
      case ActivityStatus.WALKING:
        return '行走';
      case ActivityStatus.RUNNING:
        return '跑步';
      case ActivityStatus.UNKNOWN:
      default:
        return '未知';
    }
  }

  /**
   * 获取运动状态颜色
   */
  private getActivityColor(): string {
    const actStatus: ActivityStatus = this.status?.activityStatus ?? ActivityStatus.UNKNOWN;

    switch (actStatus) {
      case ActivityStatus.STILL:
        return '#999';
      case ActivityStatus.WALKING:
        return '#1890ff';
      case ActivityStatus.RUNNING:
        return '#faad14';
      default:
        return '#999';
    }
  }
}