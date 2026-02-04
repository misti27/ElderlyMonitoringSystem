// 1. 修正导入：统一从 shared 导入
import {
  HttpUtil,
  Constants,
  User,
  UserModel,
  LoginResponse,
  LoginResponseModel,
  ElderlyStatus,
  ElderlyStatusModel,
  Alert,
  AlertModel
} from 'shared';
import { BusinessError } from '@ohos.base';

/**
 * 定义请求参数接口
 */
interface LoginParams {
  phone: string;
  password: string;
  role: string;
}

interface AlertActionParams {
  alertId: string;
}

/**
 * API服务层
 */
export class ApiService {
  /**
   * 登录
   */
  static async login(phone: string, password: string): Promise<LoginResponse> {
    try {
      const params: LoginParams = {
        phone: phone,
        password: password,
        role: 'family'
      };

      // 使用 LoginResponseModel 接口接收原始数据
      const response = await HttpUtil.post<LoginResponseModel>(Constants.API.LOGIN, params as Object);

      if (response.code === 200 && response.data) {
        return new LoginResponse(response.data);
      } else {
        throw new Error(response.message ? response.message : '登录失败');
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error('登录异常: ' + error.message);
      throw new Error(error.message);
    }
  }

  /**
   * 获取绑定的老人列表
   */
  static async getElderlyList(): Promise<User[]> {
    try {
      // 这里的路径建议在 Constants 中定义
      const response = await HttpUtil.get<UserModel[]>('/family/elderly-list');

      if (response.code === 200 && response.data) {
        // ⚠️ 修正：必须显式标注 item 的类型为接口 UserModel
        return response.data.map((item: UserModel): User => new User(item));
      } else {
        throw new Error(response.message ? response.message : '获取列表失败');
      }
    } catch (err) {
      console.error('获取老人列表失败');
      return [];
    }
  }

  /**
   * 获取老人实时状态
   */
  static async getElderlyStatus(userId: string): Promise<ElderlyStatus | null> {
    try {
      const params: Record<string, string> = {
        'userId': userId
      };

      const response = await HttpUtil.get<ElderlyStatusModel>(Constants.API.GET_STATUS, params);

      if (response.code === 200 && response.data) {
        return new ElderlyStatus(response.data);
      } else {
        return null;
      }
    } catch (err) {
      console.error('获取老人状态失败');
      return null;
    }
  }

  /**
   * 获取历史数据
   */
  static async getHistoryData(
    userId: string,
    startTime: number,
    endTime: number,
    page: number = 1
  ): Promise<ElderlyStatus[]> {
    try {
      const params: Record<string, string> = {
        'userId': userId,
        'startTime': startTime.toString(),
        'endTime': endTime.toString(),
        'page': page.toString(),
        'pageSize': Constants.PAGE_SIZE.toString()
      };

      const response = await HttpUtil.get<ElderlyStatusModel[]>(Constants.API.GET_HISTORY, params);

      if (response.code === 200 && response.data) {
        return response.data.map((item: ElderlyStatusModel): ElderlyStatus => new User(item as UserModel) as Object as ElderlyStatus);
        // 简化写法如下：
        // return response.data.map((item: ElderlyStatusModel): ElderlyStatus => new ElderlyStatus(item));
      } else {
        return [];
      }
    } catch (err) {
      console.error('获取历史数据失败');
      return [];
    }
  }

  /**
   * 获取报警列表
   */
  static async getAlertList(userId?: string, status?: string): Promise<Alert[]> {
    try {
      const params: Record<string, string> = {};
      if (userId) {
        params['userId'] = userId;
      }
      if (status) {
        params['status'] = status;
      }

      const response = await HttpUtil.get<AlertModel[]>(Constants.API.GET_ALERTS, params);

      if (response.code === 200 && response.data) {
        return response.data.map((item: AlertModel): Alert => new Alert(item));
      } else {
        return [];
      }
    } catch (err) {
      console.error('获取报警列表失败');
      return [];
    }
  }

  /**
   * 确认报警
   */
  static async confirmAlert(alertId: string): Promise<boolean> {
    try {
      const params: AlertActionParams = { alertId: alertId };
      const response = await HttpUtil.post<Object>(Constants.API.CONFIRM_ALERT, params as Object);
      return response.code === 200;
    } catch (err) {
      console.error('确认报警失败');
      return false;
    }
  }

  /**
   * 解决报警
   */
  static async resolveAlert(alertId: string): Promise<boolean> {
    try {
      const params: AlertActionParams = { alertId: alertId };
      const response = await HttpUtil.post<Object>(Constants.API.RESOLVE_ALERT, params as Object);
      return response.code === 200;
    } catch (err) {
      console.error('解决报警失败');
      return false;
    }
  }
}