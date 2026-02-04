import { FamilyStore, familyStore } from '../models/FamilyStore';
import Monitor from './Monitor';
import History from './History';
import AlertCenter from './AlertCenter';
import Device from './Device';
import { MockService } from '../services/MockService';

@Entry
@Component
struct Index {

  @Provide('familyStore') store: FamilyStore = familyStore;

  @State currentIndex: number = 0;

  aboutToAppear() {
    MockService.initMockData();
  }

  build() {
    Tabs({ index: this.currentIndex }) {
      // 1. 实时监控
      TabContent() {
        Monitor()
      }
      .tabBar(this.buildTabBar('监控', 0, $r('app.media.icon_monitor')))

      // 2. 历史数据
      TabContent() {
        History()
      }
      .tabBar(this.buildTabBar('历史', 1, $r('app.media.icon_history')))

      // 3. 报警中心 (带红点)
      TabContent() {
        AlertCenter()
      }
      .tabBar(this.buildTabBarWithBadge('报警', 2, $r('app.media.icon_alert')))

      // 4. 设备管理
      TabContent() {
        Device()
      }
      .tabBar(this.buildTabBar('设备', 3, $r('app.media.icon_device')))
    }
    .width('100%')
    .height('100%')
    .barMode(BarMode.Fixed)
    .barPosition(BarPosition.End)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  /**
   * 普通Tab栏
   */
  @Builder
  buildTabBar(title: string, index: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        // 注意：fillColor 通常只对 SVG 图标有效，如果是 PNG/JPG，可以用 .opacity() 或换图片资源来实现选中效果
        .fillColor(this.currentIndex === index ? '#1890ff' : '#999')
        .objectFit(ImageFit.Contain)

      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#1890ff' : '#999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fff') // 加上背景色，防止透底
  }

  /**
   * 带徽标的Tab栏
   */
  @Builder
  buildTabBarWithBadge(title: string, index: number, icon: Resource) {
    Column() {
      // 徽标组件
      Badge({
        count: this.store.unreadAlertCount ?? 0, // 3. 加上空值保护
        maxCount: 99,
        position: BadgePosition.RightTop,
        style: { badgeSize: 16, badgeColor: '#ff4d4f' }
      }) {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(this.currentIndex === index ? '#1890ff' : '#999')
          .objectFit(ImageFit.Contain)
      }
      .width(24) // 限制 Badge 容器宽度与图标一致
      .height(24)

      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#1890ff' : '#999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fff')
  }
}

