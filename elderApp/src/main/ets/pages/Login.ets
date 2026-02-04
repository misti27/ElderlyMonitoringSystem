import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import { HttpUtil, Constants, User, LoginResponse, UserModel } from 'shared';
import { elderlyStore } from '../models/ElderlyStore';

// 1. 定义一个专门的接口来规避 Error 136 (无类型对象字面量)
interface LoginParams {
  phone: string;
  password: string;
  role: string;
}

@Entry
@Component
struct Login {
  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMsg: string = '';

  build() {
    Column() {
      // 顶部Logo区域
      Column() {
        Text('App图标')
          .width(80)
          .height(80)
          .backgroundColor('#eee')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })
          .borderRadius(16)

        Text('老人状态监测')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        Text('守护您的安全')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 60, bottom: 40 })

      // 表单区域
      Column() {
        Column() {
          Text('手机号')
            .fontSize(14)
            .fontColor('#666')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入手机号', text: this.phone })
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .fontSize(16)
            .height(48)
            .backgroundColor('#f5f5f5')
            .onChange((value: string) => {
              this.phone = value;
              this.errorMsg = '';
            })
        }
        .width('100%')
        .margin({ bottom: 20 })

        Column() {
          Text('密码')
            .fontSize(14)
            .fontColor('#666')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(InputType.Password)
            .fontSize(16)
            .height(48)
            .backgroundColor('#f5f5f5')
            .onChange((value: string) => {
              this.password = value;
              this.errorMsg = '';
            })
        }
        .width('100%')
        .margin({ bottom: 30 })

        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#f5222d')
            .width('100%')
            .margin({ bottom: 20 })
        }

        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#fff')
          .backgroundColor(this.canLogin() ? '#1890ff' : '#ccc')
          .enabled(this.canLogin() && !this.isLoading)
          .onClick(() => {
            this.handleLogin();
          })
      }
      .width('100%')
      .padding({ left: 30, right: 30 })

      Blank()

      Text('请确保设备权限已开启')
        .fontSize(12)
        .fontColor('#999')
        .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }

  private canLogin(): boolean {
    return this.phone.length === 11 && this.password.length >= 6;
  }

  private async handleLogin(): Promise<void> {
    try {
      this.isLoading = true;
      this.errorMsg = '';

      // 2. 修正 Error 136: 使用带类型的变量代替对象字面量
      const params: LoginParams = {
        phone: this.phone,
        password: this.password,
        role: 'elderly'
      };

      const response = await HttpUtil.post<LoginResponse>(Constants.API.LOGIN, params as Object);

      // 3. 修正 Error 143: 增加更严谨的空值校验和类型转换 (as UserModel)
      if (response.code === 200 && response.data && response.data.user) {
        const userData = response.data.user as UserModel;
        const userInstance = new User(userData);
        elderlyStore.updateUser(userInstance);

        // 4. 解决 Warning 147: 完善 router 跳转的异常捕获
        try {
          router.replaceUrl({
            url: 'pages/Index'
          });
        } catch (routerError) {
          const err = routerError as BusinessError;
          console.error(`路由跳转失败: Code: ${err.code}, Message: ${err.message}`);
          this.errorMsg = '程序跳转异常';
        }
      } else {
        this.errorMsg = response.message ? response.message : '登录失败，请重试';
      }
    } catch (err) {
      // 5. 解决 Warning 2: 正确使用 BusinessError
      const error = err as BusinessError;
      console.error(`登录请求异常: ${error.message}`);
      this.errorMsg = '网络错误，请检查网络连接';
    } finally {
      this.isLoading = false;
    }
  }
}