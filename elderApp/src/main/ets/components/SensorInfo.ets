import { ElderlyStore } from '../models/ElderlyStore'
import { SensorService } from '../services/SensorService'

@Component
export default struct SensorInfo {
  @Consume('elderlyStore') store: ElderlyStore
  
  private sensorService = SensorService.getInstance()
  
  build() {
    Column() {
      Text('传感器数据')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })
      
      Column() {
        // 加速度数据
        this.buildSensorItem('加速度计', this.getAccDataText())
        
        Divider().margin({ top: 12, bottom: 12 })
        
        // 数据缓冲区
        this.buildSensorItem('缓冲区', `${this.store.sensorDataBuffer.length} 条数据`)
        
        Divider().margin({ top: 12, bottom: 12 })
        
        // 采集状态
        this.buildSensorItem('采集状态', this.store.isCollecting ? '运行中' : '已停止')
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
   * 传感器项
   */
  @Builder
  buildSensorItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666')
      
      Blank()
      
      Text(value)
        .fontSize(13)
        .fontColor('#333')
        .fontFamily('monospace')
    }
    .width('100%')
  }
  
  /**
   * 获取加速度数据文本
   */
  private getAccDataText(): string {
    try {
      const data = this.sensorService.getLastAccData()
      if (data?.x !== undefined) {
        return `X:${data.x.toFixed(2)} Y:${data.y?.toFixed(2)} Z:${data.z?.toFixed(2)}`
      }
      return '无数据'
    } catch (err) {
      return '错误'
    }
  }
}
