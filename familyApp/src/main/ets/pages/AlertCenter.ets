import { FamilyStore } from '../models/FamilyStore';
import { Alert, AlertStatus } from 'shared';

@Component
export default struct AlertCenter {
  @Consume('familyStore') store: FamilyStore;

  build() {
    Column() {
      Row() {
        Text('预警通知').fontSize(20).fontWeight(FontWeight.Bold)
        if (this.store.unreadAlertCount > 0) {
          Text(`${this.store.unreadAlertCount}`).margin({ left: 8 })
            .backgroundColor('#ff4d4f').fontColor('#fff').fontSize(12)
            .borderRadius(10).padding({ left: 6, right: 6 })
        }
        Blank()
        Text('清空已读').fontSize(14).fontColor('#1890ff')
          .onClick(() => {
            // 这里逻辑取决于你是否想重置 Store
          })
      }
      .width('100%').padding(20).backgroundColor('#fff')

      List({ space: 10 }) {
        ForEach(this.store.alertList, (alert: Alert) => {
          ListItem() {
            Row() {
              Circle({ width: 10, height: 10 })
                .fill(alert.status === AlertStatus.PENDING ? '#ff4d4f' : '#ccc')
                .margin({ right: 12 })

              Column() {
                Text(alert.content).fontSize(15).fontWeight(FontWeight.Medium)
                Text(new Date(alert.timestamp).toLocaleString()).fontSize(12).fontColor('#999').margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)

              Text(alert.status === AlertStatus.PENDING ? '待处理' : '已确认')
                .fontSize(12).fontColor(alert.status === AlertStatus.PENDING ? '#ff4d4f' : '#999')
            }
            .width('100%').padding(16).backgroundColor('#fff').borderRadius(8)
          }
        })
      }.padding(16).layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F8FAFC')
  }
}