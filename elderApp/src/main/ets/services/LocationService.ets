import geoLocationManager from '@ohos.geoLocationManager'
import {  ElderlyStatusModel, LocationData, LocationModel } from 'shared'
import { elderlyStore } from '../models/ElderlyStore'

/**
 * 定位服务
 */
export class LocationService {
  private static instance: LocationService
  
  private currentLocation: LocationData = new LocationData()
  private isTracking: boolean = false
  
  private constructor() {}
  
  /**
   * 获取单例
   */
  static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService()
    }
    return LocationService.instance
  }
  
  /**
   * 开始定位
   */
  async startTracking(): Promise<void> {
    try {
      // 检查定位权限
      const hasPermission = await this.checkLocationPermission()
      if (!hasPermission) {
        throw new Error('没有定位权限')
      }
      
      // 开启定位
      const requestInfo: geoLocationManager.LocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        timeInterval: 60,  // 60秒更新一次
        distanceInterval: 0,
        maxAccuracy: 0
      }
      
      geoLocationManager.on('locationChange', requestInfo, (location: geoLocationManager.Location) => {
        this.handleLocationUpdate(location)
      })
      
      this.isTracking = true
      console.info('定位服务已启动')
    } catch (err) {
      console.error('启动定位服务失败', err)
      throw new Error(`启动失败: ${err}`)
    }
  }
  
  /**
   * 停止定位
   */
  stopTracking(): void {
    try {
      if (this.isTracking) {
        geoLocationManager.off('locationChange')
        this.isTracking = false
        console.info('定位服务已停止')
      }
    } catch (err) {
      console.error('停止定位服务失败', err)
    }
  }
  
  /**
   * 获取当前位置
   */
  async getCurrentLocation(): Promise<LocationData> {
    try {
      const location = await geoLocationManager.getCurrentLocation()
      return new LocationData({
        latitude: location.latitude ?? 0,
        longitude: location.longitude ?? 0,
        accuracy: location.accuracy ?? 0,
        timestamp: Date.now()
      })
    } catch (err) {
      console.error('获取当前位置失败', err)
      return new LocationData()
    }
  }
  
  /**
   * 处理位置更新
   */
  private handleLocationUpdate(location: geoLocationManager.Location): void {
    try {
      const locationData = new LocationData({
        latitude: location.latitude ?? 0,
        longitude: location.longitude ?? 0,
        accuracy: location.accuracy ?? 0,
        timestamp: Date.now()
      })
      
      this.currentLocation = locationData
      
      // 更新到Store
      const statusUpdate: ElderlyStatusModel = {
        location: locationData as LocationModel
      };
      elderlyStore.updateStatus(statusUpdate);
      
      console.info('位置已更新', locationData)
    } catch (err) {
      console.error('处理位置更新失败', err)
    }
  }
  
  /**
   * 检查定位权限
   */
  private async checkLocationPermission(): Promise<boolean> {
    try {
      // 这里应该使用abilityAccessCtrl检查权限
      // 简化处理，实际项目需要完善
      return true
    } catch (err) {
      console.error('检查定位权限失败', err)
      return false
    }
  }
  
  /**
   * 获取当前位置数据
   */
  getLocation(): LocationData {
    return this.currentLocation
  }
}
