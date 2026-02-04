/**
 * 时间格式化工具类
 */
export class TimeUtil {
  /**
   * 格式化时间戳
   * @param timestamp 时间戳(ms)
   * @param format 格式字符串
   */
  static format(timestamp?: number, format: string = 'YYYY-MM-DD HH:mm:ss'): string {
    try {
      const ts = timestamp ? timestamp : Date.now();
      const date = new Date(ts);

      const year = date.getFullYear();
      const month = (date.getMonth() + 1).toString().padStart(2, '0');
      const day = date.getDate().toString().padStart(2, '0');
      const hour = date.getHours().toString().padStart(2, '0');
      const minute = date.getMinutes().toString().padStart(2, '0');
      const second = date.getSeconds().toString().padStart(2, '0');

      // ArkTS 支持连续 replace
      return format
        .replace('YYYY', year.toString())
        .replace('MM', month)
        .replace('DD', day)
        .replace('HH', hour)
        .replace('mm', minute)
        .replace('ss', second);
    } catch (err) {
      console.error('时间格式化失败');
      return '';
    }
  }

  /**
   * 获取相对时间描述
   * @param timestamp 时间戳(ms)
   */
  static relative(timestamp?: number): string {
    try {
      const now = Date.now();
      const time = timestamp ? timestamp : now;
      const diff = now - time;

      if (diff < 60 * 1000) {
        return '刚刚';
      } else if (diff < 60 * 60 * 1000) {
        const minutes = Math.floor(diff / (60 * 1000));
        return minutes.toString() + '分钟前';
      } else if (diff < 24 * 60 * 60 * 1000) {
        const hours = Math.floor(diff / (60 * 60 * 1000));
        return hours.toString() + '小时前';
      } else if (diff < 7 * 24 * 60 * 60 * 1000) {
        const days = Math.floor(diff / (24 * 60 * 60 * 1000));
        return days.toString() + '天前';
      } else {
        // ⚠️ 修正点：将 this.format 改为 TimeUtil.format
        // 解决 arkts-no-standalone-this 报错
        return TimeUtil.format(time, 'YYYY-MM-DD');
      }
    } catch (err) {
      console.error('相对时间计算失败');
      return '';
    }
  }

  /**
   * 获取今天日期范围
   */
  static getTodayRange(): [number, number] {
    const now = new Date();
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const end = start + 24 * 60 * 60 * 1000 - 1;
    return [start, end];
  }

  /**
   * 获取本周日期范围
   */
  static getWeekRange(): [number, number] {
    const now = new Date();
    const day = now.getDay();
    const diff = day === 0 ? 6 : day - 1;
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate() - diff).getTime();
    const end = start + 7 * 24 * 60 * 60 * 1000 - 1;
    return [start, end];
  }
}