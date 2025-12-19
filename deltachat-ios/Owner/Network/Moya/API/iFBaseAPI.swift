
// ... 你的代码 ...



import Foundation
import Moya
import SwiftUI

// swiftlint:disable all
enum  iFBaseAPI {
    
    case sendPhoneMessageCode(countryCode:String,phone: String,codeType:Int)
    
    case phoneCodeLogin(countryCode:String,phone: String,code:String)
    
    case setPwd(pwd:String)
    
    case changePwd(pwd:String,code:String)
    
    
    case phonePWDLogin(countryCode:String,phone: String,pwd:String)
    
    
    case getUserInfo
    
    case updateUserInfo(avatarFileId:String?,nickName: String?,birthday:String?,gender:String?)
    
    ///退出登录
    case logout
    ///注销账号
    case delecteAccount
    case bindPhone(phone: String, event: Int,loginType:Int,thirdPartyId:String,verCode:String ,areaCode:String)
    
    
    case wechatLogin(openId:String,unionId:String,accessToken:String,wxUserNickeName:String,wxUserSex:String,wxUserHeadimgurl:String,country:String,province:String,city:String)
    
    case vistorLogin
    
    case uploadImages(images:[UIImage])
    
    case productList
    
    case agreement
    
    case feature(firmwareVersion:String,vendorId:Int,modelId:Int)
    
    case reportMonth(vendorId:Int,modelId:Int,bleAddress:String,month:String)
    
    case reportWeek(vendorId:Int,modelId:Int,bleAddress:String,startTime:String,endTime:String)

    case reportDayCalendar(vendorId:Int,modelId:Int,bleAddress:String,month:String)

    case bindDevice(vendorId:Int,modelId:Int,bleAddress:String,firmwareVersion:String,deviceName:String,colorId:Int)
    
//    {"domain":"aa1234.com","address":"test12@aa1234.com","password":"123456"}
    case createAccount(domain:String,address:String,password:String)

case firmwareUpdate(vendorId:Int,modelId:Int,firmwareVersion:String)
}


// 补全【MoyaConfig 3：配置TargetType协议可以一次性处理的参数】中没有处理的参数
extension iFBaseAPI: TargetType {
    //1. 每个接口的相对路径
    //请求时的绝对路径是   baseURL + path
    var path: String {
        switch self {
            
        case .sendPhoneMessageCode:
            
            return "/auth/code/phone"
        case .phoneCodeLogin:
            return "/auth/login/phone/code"
            
        case .setPwd:
            return "/user/setting/password";
        case .changePwd:
            return "/user/update/password"
        case .getUserInfo:
            return "/user"
            
        case .updateUserInfo:
            return "/user/update"
            
        case .phonePWDLogin:
            return "/auth/login/phone"
            
        case .logout:
            return "/auth/logout"
        case .delecteAccount:
            return "/user/cancelAccount"
            
        case .bindPhone:
            return "/user/thirdParty/bindPhoneOrEmail"
        case .wechatLogin:
            return "/user/thirdParty/weChatLogin"
        case .vistorLogin:
            return "/user/thirdParty/visitorLogin"
        case .uploadImages:
            return "/file/app/upload"
        case .productList:
            return "/product/list"
        case .agreement :
            return "/agreement"
        case .feature:
            //            return "/feature"
            
            return "/feature/map"
        case .reportMonth:
            return "/report/month"

        case .reportWeek:
            return "/report/week"
            
        case .reportDayCalendar:
            return "/report/day/calendar"
            
        case .bindDevice:
            
            return "/device/add"
        case .firmwareUpdate:

            return "/firmware"

        case .createAccount:
            //http://aa.aa1234.com/create-account
            return "/create-account"

        default: return ""
        }
    }
    
    //2. 每个接口要使用的请求方式
    var method: Moya.Method {
        
        switch self {
        case .getUserInfo,.productList,.agreement:
            return .get
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
            
        case let .sendPhoneMessageCode(countryCode, phone, codeType):
            params["countryCode"] = countryCode //区号(不传默认 86)
            params["phone"] = phone
            params["codeType"] = codeType//类型 1 登录, 2 绑定账号, 3 设置密码,可用值:1,2,3
            
        case let .phoneCodeLogin(countryCode, phone, code):
            
            params["countryCode"] = countryCode //区号(不传默认 86)
            params["phone"] = phone
            params["code"] = code//类型 1 登录, 2 绑定账号, 3 设置密码,可用值:1,2,3
            
        case let .setPwd(pwd):
            params["password"] = pwd
            
        case let .changePwd(pwd, code):
            params["password"] = pwd
            params["code"] = code
            
            
        case let .phonePWDLogin(countryCode, phone, pwd):
            params["countryCode"] = countryCode //区号(不传默认 86)
            params["phone"] = phone
            params["password"] = pwd//类型 1 登录, 2 绑定账号, 3 设置密码,可用值:1,2,3
            
        case let .updateUserInfo(avatarFileId, nickName, birthday, gender):
            
            if let avatarFileId = avatarFileId {
                params["avatarFileId"] = avatarFileId
                
            }
            
            if let nickName = nickName {
                params["nickName"] = nickName
                
            }
            
            if let birthday = birthday {
                params["birthday"] = birthday
                
            }
            
            
            if let gender = gender {
                params["gender"] = gender
                
            }
            
            
            
            
            
        case .logout: /// 后台说不能传 空 的body  怎么会有这样的后台？？？？？？
            params["Test"] = "okok"
        case .delecteAccount: /// 后台说不能传 空 的body 怎么会有这样的后台？？？？？？
            params["Test"] = "okok"
        case let .bindPhone(phone, event, loginType, thirdPartyId,verCode,areaCode):
            params["type"] = "1" //类型 1手机号 2邮箱
            params["phone"] = phone;
            params["verCode"] = verCode;
            
            params["paramType"] = event; //1用户注册，2登录，3重置密码  4注销
            params["loginType"] = loginType;//0 微信 1微博 2facebook 3apple 5账号注册 null ：账号注册
            params["thirdPartyId"] = thirdPartyId;
            params["areaCode"] = areaCode;
            
            
        case let .wechatLogin(openId, unionId, accessToken, wxUserNickeName, wxUserSex, wxUserHeadimgurl, country,province,city):
            params["openId"] = openId;
            params["unionId"] = unionId;
            params["accessToken"] = accessToken;
            params["wxUserNickeName"] = wxUserNickeName;
            params["wxUserSex"] = wxUserSex;
            params["wxUserHeadimgurl"] = wxUserHeadimgurl;
            params["country"] = country;
            params["province"] = province;
            params["city"] = city;
            
        case .vistorLogin:
            
            params["city"] = "city";
        case let .feature(firmwareVersion, vendorId, modelId):
            
            params["firmwareVersion"] = firmwareVersion;
            params["vendorId"] = vendorId;
            params["modelId"] = modelId;
    
        case let .reportMonth(vendorId, modelId, bleAddress, month):
            params["bleAddress"] = bleAddress;
            params["vendorId"] = vendorId;
            params["modelId"] = modelId;
            params["month"] = month;
        case let .reportWeek(vendorId, modelId, bleAddress, startTime, endTime):
            params["bleAddress"] = bleAddress;
            params["vendorId"] = vendorId;
            params["modelId"] = modelId;
            params["startTime"] = startTime;
            params["endTime"] = endTime;
            
        case let .reportDayCalendar(vendorId, modelId, bleAddress, month):
            params["bleAddress"] = bleAddress;
            params["vendorId"] = vendorId;
            params["modelId"] = modelId;
            params["month"] = month;

        case let .bindDevice(vendorId, modelId, bleAddress, firmwareVersion, deviceName, colorId):
            params["bleAddress"] = bleAddress;
            params["vendorId"] = vendorId;
            params["modelId"] = modelId;
            params["firmwareVersion"] = firmwareVersion;
            params["deviceName"] = deviceName;
            params["colorId"] = colorId;
            
        case let .firmwareUpdate(vendorId, modelId, firmwareVersion):
            params["vendorId"] = vendorId;
            params["modelId"] = modelId;
            params["firmwareVersion"] = firmwareVersion;
        case let .uploadImages(images):
            var formDataAry = [Moya.MultipartFormData]();
            for (index,image) in images.enumerated() {
                
                autoreleasepool {
                    //图片转成Data
                    let data:Data = image.jpegData(compressionQuality: 0.75) ?? Data.init()
                    //根据当前时间设置图片上传时候的名字
                    let date:Date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
                    var dateStr:String = formatter.string(from: date as Date)
                    //别忘记这里给名字加上图片的后缀哦
                    dateStr = dateStr.appendingFormat("-%i.jpeg", index)
                    let formData = MultipartFormData(provider: .data(data), name: "file", fileName: dateStr, mimeType: "image/jpeg")
                    formDataAry.append(formData);
                }
                
                
            }
            return .uploadMultipart(formDataAry);
            
        default:
            return .requestPlain
        }
        let data = (try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.init(rawValue: 0))) ?? Data()
        return .requestData(data)
        
    }
    
}

// swiftlint:enable all
