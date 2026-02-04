import { FamilyStore } from '../models/FamilyStore';
import { ElderlyStatus } from 'shared';

@Component
export default struct History {
  @Consume('familyStore') store: FamilyStore;

  build() {
    Column() {
      Text('历史健康轨迹').fontSize(20).fontWeight(FontWeight.Bold).width('100%').padding(20)

      if (this.store.historyList.length === 0) {
        Column() { Text('暂无历史记录').fontColor('#999').margin({ top: 100 }) }.width('100%')
      } else {
        List({ space: 12 }) {
          ForEach(this.store.historyList, (item: ElderlyStatus) => {
            ListItem() {
              Row() {
                Column() {
                  Text(new Date(item.timestamp).toLocaleDateString()).fontSize(14).fontWeight(FontWeight.Medium)
                  Text(new Date(item.timestamp).toLocaleTimeString()).fontSize(12).fontColor('#999')
                }.alignItems(HorizontalAlign.Start)

                Blank()

                Text(`${item.heartRate} bpm`).fontSize(16).fontColor('#ff4d4f').fontWeight(FontWeight.Bold)
              }
              .width('100%').padding(16).backgroundColor('#fff').borderRadius(12)
            }
          })
        }.padding(16).height('100%').width('100%')
      }
    }
    .width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}