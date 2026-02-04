@Component
export default struct StatusCard {
  @Prop isRunning: boolean = false
  @Prop lastUpdateTime: string = ''
  
  build() {
    Column() {
      // 状态指示器
      Row() {
        Circle()
          .width(12)
          .height(12)
          .fill(this.isRunning ? '#52c41a' : '#d9d9d9')
        
        Text(this.isRunning ? '监测中' : '未运行')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isRunning ? '#52c41a' : '#999')
          .margin({ left: 8 })
        
        Blank()
        
        if (this.isRunning) {
          Text('正常')
            .fontSize(14)
            .fontColor('#52c41a')
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .backgroundColor('#f6ffed')
            .borderRadius(4)
        }
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 更新时间
      if (this.lastUpdateTime) {
        Text(`最后更新: ${this.lastUpdateTime}`)
          .fontSize(12)
          .fontColor('#999')
          .alignSelf(ItemAlign.Start)
      }
      
      // 提示信息
      if (this.isRunning) {
        Text('系统正在后台监测您的状态，请保持应用运行')
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 12 })
          .lineHeight(18)
      } else {
        Text('点击下方按钮开始监测')
          .fontSize(12)
          .fontColor('#999')
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(8)
  }
}
