import router from '@ohos.router';
import { ElderlyStore, elderlyStore } from '../models/ElderlyStore';
import { BusinessError } from '@ohos.base';
import promptAction from '@ohos.promptAction';

@CustomDialog
struct PhoneInputDialog {
  // 修复之前的初始化报错
  controller: CustomDialogController = new CustomDialogController({ builder: "" });
  @State phoneInput: string = '';
  onConfirm: (phone: string) => void = (phone: string) => {};

  build() {
    Column() {
      Text('设置紧急联系电话').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
      TextInput({ placeholder: '请输入11位手机号', text: this.phoneInput })
        .type(InputType.Number).maxLength(11).height(56).backgroundColor('#F5F5F5')
        .onChange((value) => { this.phoneInput = value; })
        .margin({ bottom: 24 })
      Row({ space: 12 }) {
        Button('取消').fontSize(18).backgroundColor('#F5F5F5').fontColor('#666').layoutWeight(1)
          .onClick(() => { this.controller.close(); })
        Button('确定').fontSize(18).backgroundColor('#007AFF').fontColor('#FFF').layoutWeight(1)
          .onClick(() => {
            if (this.phoneInput.length !== 11) {
              promptAction.showToast({ message: '请输入正确的11位手机号' });
              return;
            }
            this.onConfirm(this.phoneInput);
            this.controller.close();
          })
      }.width('100%')
    }.padding(24).backgroundColor('#FFF').borderRadius(20)
  }
}

@Entry
@Component
struct Settings {
  @State store: ElderlyStore = elderlyStore;
  private phoneDialogController: CustomDialogController | null = null;

  build() {
    Column() {
      // 1. 标题栏 (使用 Stack 实现绝对居中)
      Stack({ alignContent: Alignment.Center }) {
        Text('系统设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Row() {
          Text('‹ 返回')
            .fontSize(18)
            .fontColor('#007DFF')
            .onClick(() => router.back())
        }
        .width('100%')
        .justifyContent(FlexAlign.Start) // 让返回按钮靠左
        .hitTestBehavior(HitTestMode.Transparent) // 让触摸穿透，防止挡住中间
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFF')

      // 2. 设置列表区域
      Scroll() {
        // ⚠️ 关键修复：这里的 justifyContent 必须是 Start (顶部对齐)
        Column() {
          Text('安全绑定')
            .fontSize(14)
            .fontColor('#999')
            .margin({ left: 16, top: 24, bottom: 8 })
            .alignSelf(ItemAlign.Start)

          // 设置项卡片
          Column() {
            this.buildSettingItem(
              '紧急联系电话',
              this.store.user.emergencyPhone || '未设置',
              () => this.showPhoneInputDialog()
            )
            Divider().margin({ left: 16, right: 16 }).color('#F5F5F5')
            this.buildSettingItem('系统版本', 'v1.0.0 (最新)', () => {})
          }
          .backgroundColor('#FFF')
          .borderRadius(16)
          .margin({ left: 16, right: 16 })

          // 退出按钮
          Button('退出当前账号')
            .width('90%')
            .height(56) // 加高一点，更适合老人
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF')
            .border({ width: 1, color: '#FF4D4F' }) // 红色边框更醒目
            .borderRadius(16)
            .margin({ top: 60 }) // 距离上方卡片一段距离，而不是居中
            .onClick(() => this.showLogoutDialog())

        }
        // ⚠️ 关键修复：强制内容顶部对齐
        .justifyContent(FlexAlign.Start)
        .width('100%')
        // 注意：不要在这里加 .height('100%')，否则可能导致内部居中
      }
      .layoutWeight(1) // 占满剩余空间
      .align(Alignment.Top) // ⚠️ 关键修复：Scroll 内部对齐方式设为顶部
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA') // 浅灰背景
  }

  @Builder
  buildSettingItem(label: string, value: string, onClick: () => void) {
    Row() {
      Text(label).fontSize(18).fontColor('#333')
      Blank()
      Text(value).fontSize(18).fontColor('#999').margin({ right: 8 })
      Text('›').fontSize(24).fontColor('#CCC').margin({ top: -2 }) // 微调箭头位置
    }
    .width('100%')
    .height(72) // 适老化高度
    .padding({ left: 20, right: 20 })
    .onClick(onClick)
  }

  private showPhoneInputDialog(): void {
    this.phoneDialogController = new CustomDialogController({
      builder: PhoneInputDialog({
        phoneInput: this.store.user.emergencyPhone,
        onConfirm: (phone: string) => {
          this.store.updateEmergencyPhone(phone);
          promptAction.showToast({ message: '紧急号码已保存' });
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    this.phoneDialogController.open();
  }

  private showLogoutDialog(): void {
    try {
      AlertDialog.show({
        title: '退出登录',
        message: '确定要退出并停止监测吗？',
        primaryButton: { value: '取消', action: () => {} },
        secondaryButton: {
          value: '确定',
          fontColor: '#D0021B',
          action: () => {
            this.store.reset();
            router.replaceUrl({ url: 'pages/Login' });
          }
        }
      });
    } catch (err) {
      const error = err as BusinessError;
      console.error('退出异常: ' + error.message);
    }
  }
}