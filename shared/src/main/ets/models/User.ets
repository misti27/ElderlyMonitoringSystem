/**
 * 定义接口用于构造函数传参，规避 Partial 不支持的问题
 */
export interface UserModel {
  id?: string;
  username?: string;
  name?: string;
  phone?: string;
  emergencyPhone?: string;
  role?: string;      // 角色：'elderly' | 'family'
  bindDeviceId?: string;
}

/**
 * 用户数据模型
 */
export class User {
  id: string = '';
  username: string = '';
  name: string = '';
  emergencyPhone: string = '';
  phone: string = '';
  role: string = 'elderly';
  bindDeviceId: string = '';

  constructor(data?: UserModel) {
    if (data) {
      this.id = data.id ?? '';
      this.username = data.username ?? '';
      this.name = data.name ?? data.username ?? ''; // 如果传了name就用name，否则退而求其次用username
      this.emergencyPhone = data.emergencyPhone ?? '';
      this.phone = data.phone ?? '';
      this.role = data.role ?? 'elderly';
      this.bindDeviceId = data.bindDeviceId ?? '';
    }
  }
}

/**
 * 登录响应数据接口
 */
export interface LoginResponseModel {
  token?: string;
  user?: UserModel;
}

/**
 * 登录响应数据
 */
export class LoginResponse {
  token: string = '';
  user: User = new User();

  constructor(data?: LoginResponseModel) {
    if (data) {
      this.token = data.token ?? '';
      this.user = data.user ? new User(data.user) : new User();
    }
  }
}