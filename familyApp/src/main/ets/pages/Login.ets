import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import { HttpUtil, Constants, User, LoginResponse, UserModel } from 'shared';
import { familyStore } from '../models/FamilyStore';

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

  private async handleLogin(): Promise<void> {
    const params: LoginParams = { phone: this.phone, password: this.password, role: 'family' };
    try {
      const response = await HttpUtil.post<LoginResponse>(Constants.API.LOGIN, params as Object);
      if (response.code === 200 && response.data) {
        // 保存子女自己的信息
        familyStore.user = new User(response.data.user as UserModel);
        // ⚠️ 关键：子女登录后通常会返回关联的老人列表
        // if (response.data.elderlyList) { familyStore.setElderlyList(response.data.elderlyList); }
        router.replaceUrl({ url: 'pages/Index' });
      }
    } catch (err) {
      console.error('登录失败');
    }
  }

  build() {
    // 布局代码参考老人端即可
    Column() { Text('子女端登录').fontSize(30); /* ... */ }
  }
}