import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { Constants } from '../constants/Constants';

/**
 * HTTP请求响应接口定义
 */
export interface HttpResponse<T> {
  code: number;
  message: string;
  data?: T;
}

/**
 * HTTP请求工具类
 */
export class HttpUtil {
  /**
   * 获取Token
   */
  private static getToken(): string {
    try {
      // 实际项目中需要从首选项(Preferences)获取
      return '';
    } catch (err) {
      console.error('获取token失败');
      return '';
    }
  }

  /**
   * GET请求
   */
  static async get<T>(url: string, params?: Record<string, string>): Promise<HttpResponse<T>> {
    const httpRequest = http.createHttp();
    try {
      const fullUrl = HttpUtil.buildUrl(url, params);

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + HttpUtil.getToken()
        },
        connectTimeout: 10000,
        readTimeout: 10000
      });

      return HttpUtil.parseResponse<T>(response);
    } catch (err) {
      const error = err as BusinessError;
      console.error('GET请求失败', JSON.stringify(error));
      throw new Error(error.message);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * POST请求
   * ⚠️ data 使用 Object 类型代替 any
   */
  static async post<T>(url: string, data?: Object): Promise<HttpResponse<T>> {
    const httpRequest = http.createHttp();
    try {
      const fullUrl = Constants.API_BASE_URL + url;

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + HttpUtil.getToken()
        },
        // ⚠️ 修正点：确保 data 有值，否则传空对象字符串
        extraData: JSON.stringify(data ? data : {}),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      return HttpUtil.parseResponse<T>(response);
    } catch (err) {
      const error = err as BusinessError;
      console.error('POST请求失败', JSON.stringify(error));
      throw new Error(error.message);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 构建URL
   * ⚠️ 修正点：重写参数拼接逻辑，避开 Object.entries 及其解构
   */
  private static buildUrl(url: string, params?: Record<string, string>): string {
    let fullUrl = Constants.API_BASE_URL + url;

    if (params) {
      const keys = Object.keys(params);
      if (keys.length > 0) {
        let queryString = '';
        for (let i = 0; i < keys.length; i++) {
          const key = keys[i];
          const value = params[key];
          queryString += (i === 0 ? '?' : '&') + key + '=' + encodeURIComponent(value);
        }
        fullUrl += queryString;
      }
    }

    return fullUrl;
  }

  /**
   * 解析响应
   * ⚠️ 修正点：显式转换 JSON 解析结果
   */
  private static parseResponse<T>(response: http.HttpResponse): HttpResponse<T> {
    if (response.responseCode === 200) {
      try {
        const resultString = response.result as string;
        // 强制转换解析后的对象为目标接口类型
        const result = JSON.parse(resultString) as HttpResponse<T>;
        return result;
      } catch (err) {
        throw new Error('响应格式解析失败');
      }
    } else {
      throw new Error('服务器响应异常: ' + response.responseCode.toString());
    }
  }
}