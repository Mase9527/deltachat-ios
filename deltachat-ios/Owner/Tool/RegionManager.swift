import Foundation
import CoreTelephony

class RegionManager {
    static let shared = RegionManager()
    
    private init() {}
    
    /// 判断是否在中国大陆地区
    /// 综合判断：SIM卡信息、设备语言区域、时区
    var isMainlandChina: Bool {
        // 1. 优先检查 SIM 卡信息 (最准确)
        if let carrierCode = getCarrierRegionCode(), !carrierCode.isEmpty {
            return carrierCode.uppercased() == "CN"
        }
        
        // 2. 检查设备区域设置 (用户可修改)
        if let regionCode = Locale.current.regionCode {
            return regionCode.uppercased() == "CN"
        }
        
        // 3. 检查系统语言 (辅助判断)
        if let language = Locale.preferredLanguages.first {
            return language.hasPrefix("zh-Hans")
        }
        
        return false
    }
    
    /// 获取 SIM 卡所属国家/地区代码
    private func getCarrierRegionCode() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        
        // iOS 12+ 支持双卡，这里检查所有提供商
        if #available(iOS 12.0, *), let providers = networkInfo.serviceSubscriberCellularProviders {
            for (_, carrier) in providers {
                if let isoCountryCode = carrier.isoCountryCode {
                    return isoCountryCode
                }
            }
        } else {
            // 旧版本单卡
            if let carrier = networkInfo.subscriberCellularProvider,
               let isoCountryCode = carrier.isoCountryCode {
                return isoCountryCode
            }
        }
        
        return nil
    }
}
