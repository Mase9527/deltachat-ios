import Foundation
import Moya

import DeviceKit
import UIKit
// swiftlint:enable all


#warning("下面的代码需要根据项目进行更改")
/**
 1.状态码 根据自家后台数据更改
 
 - Todo: 根据自己的需要更改
 **/
enum HttpCode : Int {
    case success = 200 //请求成功的状态吗
    case needLogin = 401  // 返回需要登录的错误码
    case tokenInvate = 110026 // 用户信息已失效
}

/**
 2.为了统一处理错误码和错误信息，在请求回调里会用这个model尝试解析返回值
 - Todo: 根据自家后台更改。
 **/
struct BaseModel: Decodable {
    var code: Int
    var data: Content
    var message:String
    var success:Bool
    var error:String
    struct Content: Decodable {
        var message: String
    }
}

//下面的错误码及错误信息用来在HttpRequest中使用
extension BaseModel {
    var generalCode: Int {
        return code
    }
    
    var generalMessage: String {
        let  errMsgCount = self.message.count
        if errMsgCount != 0 {
            return self.message
        }
        return data.message.isEmpty == true ? self.message:data.message
    }
}

/**
 3.配置TargetType协议可以一次性处理的参数
 
 - Todo: 根据自己的需要更改，不能统一处理的移除下面的代码，并在DMAPI中实现
 
 **/
public extension TargetType {
    var baseURL: URL {
        // 开发服务器
        return URL(string: "http://aa.aa1234.com")!
    }
    
    var headers: [String : String]? {
        let device = Device.current
        var headParms =  [
            "appVerson": "kAppBundleVersion",
            "qId":"2",//1安卓 2iOS
            "Accept-Language":"zh_cn,zh;q=0.5",
//            "language":IFLocalizable.shared().langCode,
//            "lang":IFLocalizable.shared().langCode,
            "mobile":device.description,//手机型号
            "systemOs":"iOS,"+(device.systemVersion ?? ""),// 手机系统
            "Content-Type":"application/json",
//            "country":IFLocalizable.shared().country,
            "timezone":TimeZone.current.identifier
        ]
        
  
        return headParms
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
}

/**
 4.公共参数
 
 - Todo: 配置公共参数，例如所有接口都需要传token，version，time等，就可以在这里统一处理
 
 - Note: 接口传参时可以覆盖公共参数。下面的代码只需要更改 【private var commonParams: [String: Any]?】
 
 **/
extension URLRequest {
    //TODO：处理公共参数
    private var commonParams: [String: Any]? {
        //所有接口的公共参数添加在这里例如：
        return [
            :
//            "token": "123456",
//                "version": kAppBundleVersion
        ]
    }
}

//下面的代码不更改
class RequestHandlingPlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutateableRequest = request
        return mutateableRequest.appendCommonParams();
    }
}


class RequestLoadingPlugin: PluginType {
    
    //协议方法
// 在一个请求发起前，可以动态修改URLRequest里的内容，做一些调整，比如重设request的超时时间、缓存策略、Cookies设置、允许移动网络等；
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        print("[Network Request] : \(request.url?.absoluteString ?? "")")
        return request
    }
    
    // 发起请求
    func willSend(_ request: RequestType, target: TargetType) {
        print("[Network Request Target] : \(target)")
        print("请求开始")
//        HMHUD.show()
    }

    
    // 收到服务器响应
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType){
        print("请求完成")
//        HMHUD.hide()
    }

    /// // 处理返回数据，可以对数据做一些操作
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError>{
        print("进度完成")
        return result
    }
    
    
}


///打印日志
//let networkLoggerPlugin = NetworkLoggerPlugin(verbose: true, cURL: true, requestDataFormatter: { data -> String in
//    return String(data: data, encoding: .utf8) ?? ""
//}) { data -> (Data) in
//    do {
//        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
//        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
//        return prettyData
//    } catch {
//        return data
//    }
//}

let networkLoggerPlugin = NetworkLoggerPlugin()

//下面的代码不更改
extension URLRequest {
    mutating func appendCommonParams() -> URLRequest {
        let request = try? encoded(parameters: commonParams, parameterEncoding: URLEncoding(destination: .queryString))
        assert(request != nil, "append common params failed, please check common params value")
        return request!
    }
    
    func encoded(parameters: [String: Any]?, parameterEncoding: ParameterEncoding) throws -> URLRequest {
        do {
            return try parameterEncoding.encode(self, with: parameters)
        } catch {
            throw MoyaError.parameterEncoding(error)
        }
    }
}

// swiftlint:enable all
