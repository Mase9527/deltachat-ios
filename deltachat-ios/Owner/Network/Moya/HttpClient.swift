// swiftlint:enable all

import Foundation
import Moya
// swiftlint:enable all
typealias HMRequestModelsSuccessCallback<C:Codable> = ((C) -> Void)

class HttpClient {
    
    public static let shareInstance = HttpClient();
    
    private init() {
        
    }
    
    
    public func request<T: TargetType>(target:T, success: @escaping((Data) -> Void), failure: ((Int?,String)->Void)? = nil ) {
        //请求成功进行再次刷新数据
        HttpRequest.loadData(target:target, needCache: false, success: success, failure: failure)
    }
    
    public func requestModel<T: TargetType,C:Codable>(target:T, modelType:C.Type ,success: @escaping(HMRequestModelsSuccessCallback<C?>), failure: ((Int?,String)->Void)? = nil ) {
        
        HttpRequest.loadData(target: target, success: { (data) in
            let model = try? JSONDecoder().decode(C.self, from: data)
            success(model)
        }, failure: failure)
    }
    
    public func requestNOLoading<T: TargetType>(target:T, success: @escaping((Data) -> Void), failure: ((Int?,String)->Void)? = nil ) {
        //请求成功进行再次刷新数据
        HttpRequest.loadData(target:target, needCache: false,showLoading: false, success: success, failure: failure)
    }
    
    public func requestNOLoadingModel<T: TargetType,C:Codable>(target:T, modelType:C.Type ,success: @escaping(HMRequestModelsSuccessCallback<C?>), failure: ((Int?,String)->Void)? = nil ) {
        //请求成功进行再次刷新数据
        HttpRequest.loadData(target:target, needCache: false,showLoading: false, success: { (data) in
            let model = try? JSONDecoder().decode(C.self, from: data)
            success(model)
        }, failure: failure)
    }


    
    
    ///支持缓存的网络请求
    public func requestCache<T: TargetType>(target:T, success: @escaping((Data) -> Void), failure: ((Int?,String)->Void)? = nil ) {
        //请求成功进行再次刷新数据
               HttpRequest.loadData(target:target, needCache: true,success: success, failure: failure)
    }
    
    ///支持缓存的网络请求
    public func requestCacheNoLoading<T: TargetType>(target:T, success: @escaping((Data) -> Void), failure: ((Int?,String)->Void)? = nil ) {
        //请求成功进行再次刷新数据
               HttpRequest.loadData(target:target, needCache: true,showLoading: false,success: success, failure: failure)
    }
    
    public func requestCacheModel<T: TargetType,C:Codable>(target:T, modelType:C.Type ,success: @escaping(HMRequestModelsSuccessCallback<C?>), failure: ((Int?,String)->Void)? = nil ) {
        //请求成功进行再次刷新数据
        HttpRequest.loadData(target:target, needCache: true,showLoading: false, success: { (data) in
            let model = try? JSONDecoder().decode(C.self, from: data)
            success(model)
        }, failure: failure)
    }
    
    

    public func uploadData<T: TargetType>(target:T, processCallback:((Double) -> Void)? = nil,success: @escaping((Data) -> Void), failure: ((Int?,String)->Void)? = nil ) {
        //请求成功进行再次刷新数据
        HttpRequest.uploadData(target:target,processCallback: processCallback,success: success, failure: failure)
    }
    
    
}
// swiftlint:enable all
