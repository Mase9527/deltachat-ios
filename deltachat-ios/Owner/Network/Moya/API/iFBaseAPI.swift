
// ... 你的代码 ...



import Foundation
import Moya
import SwiftUI

// swiftlint:disable all
enum  iFBaseAPI {

    
//    {"domain":"aa1234.com","address":"test12@aa1234.com","password":"123456"}
    case createAccount(domain:String,address:String,password:String)
    case bindRecoveryRequest(main_email:String,recovery_email:String)
    case bindRecoveryVerify(token:String,code:String)

    case resetPasswordRequest(main_email:String)
    case resetPasswordVerify(token:String,code:String,password:String)

    case getRecoveryEmail(main_email:String)
    
    case checkEmail(address:String)



}


// 补全【MoyaConfig 3：配置TargetType协议可以一次性处理的参数】中没有处理的参数
extension iFBaseAPI: TargetType {
    //1. 每个接口的相对路径
    //请求时的绝对路径是   baseURL + path
    var path: String {
        switch self {
            
      

        case .createAccount:
            //http://aa.aa1234.com/create-account
            return "/create-account"
        case .bindRecoveryRequest:
            return "/bind-recovery-request"
        case .bindRecoveryVerify:
            return "/bind-recovery-verify"
        case .resetPasswordRequest:
            return "/reset-password-request"

        case .resetPasswordVerify:
            return "/reset-password-verify"

        case .getRecoveryEmail:
            return "/get-recovery-email"
        case .checkEmail:
            return "check-email-exists"
        default: return ""
        }
    }
    
    //2. 每个接口要使用的请求方式
    var method: Moya.Method {
        
        switch self {
        case .createAccount:
            return .post
        default:
            return .post
            
        }
    }
    
    //3. Task是一个枚举值，根据后台需要的数据，选择不同的http task。
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
            
        case let .createAccount(domain, address, password):
            params["domain"] = domain //区号(不传默认 86)
            params["address"] = address
            params["password"] = password//类型 1 登录, 2 绑定账号, 3 设置密码,可用值:1,2,3
            
        case let .bindRecoveryRequest(main_email, recovery_email):
            params["main_email"] = main_email //区号(不传默认 86)
            params["recovery_email"] = recovery_email
        case let .bindRecoveryVerify(token, code):
            params["token"] = token //区号(不传默认 86)
            params["code"] = code
        case let .resetPasswordRequest(main_email):
            params["main_email"] = main_email
        case let .resetPasswordVerify(token, code, password):
            params["token"] = token //区号(不传默认 86)
            params["code"] = code
            params["password"] = password
        case let .getRecoveryEmail(main_email):
            params["main_email"] = main_email
        case let .checkEmail(address):
            params["address"] = address

        default:
            return .requestPlain
        }
        let data = (try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.init(rawValue: 0))) ?? Data()
        return .requestData(data)
        
    }
    
}

// swiftlint:enable all
