
import Foundation
import Moya

// swiftlint:enable all
public class HttpRequest {
    
    
    /// 使用moya的请求封装
    ///
    /// - Parameters:
    ///   - target: TargetType里的枚举值
    ///   -needCache: 是否缓存
    ///   -cache: 需要单独处理缓存的数据时使用，（默认为空，使用success处理缓存数据）
    ///   - success: 成功的回调
    ///   - error: 连接服务器成功但是数据获取失败
    ///   - failure: 连接服务器失败
    public class func loadData<T: TargetType>(target: T, needCache: Bool = false, showLoading:Bool = true, showfailureMsg:Bool = true, cache: ((Data) -> Void)? = nil, success: @escaping((Data) -> Void), failure: ((Int?, String) ->Void)? ) {
        
        var networkProvider:MoyaProvider<T>!
        
        if showLoading == true {
            let provider = MoyaProvider<T>(plugins: [
                RequestHandlingPlugin(),
                RequestLoadingPlugin(),
                MoyaLoggingPlugin()
//                NetworkLoggerPlugin.verbose
                
            ])
            networkProvider = provider
        }else{
            let provider = MoyaProvider<T>(plugins: [
                RequestHandlingPlugin(),
                MoyaLoggingPlugin()

//                NetworkLoggerPlugin.verbose

            ])
            networkProvider = provider
        }
        
        
        //如果需要读取缓存，则优先读取缓存内容
        if needCache, let data = SaveFiles.read(path: target.path) {
            //cache不为nil则使用cache处理缓存，否则使用success处理
            if let block = cache {
                block(data)
            }else {
                success(data)
            }
        }else {
            //读取缓存速度较快，无需显示hud；仅从网络加载数据时，显示hud。
            if showLoading {
            }
        }
        networkProvider.request(target) { result in
            switch result {
            case let .success(response):
                parseSucessResponse(target:target,response: response, success: success, failure: failure)
            // ********************
            case let .failure(error):
                let statusCode = error.response?.statusCode ?? 0
                let errorCode = "请求出错，错误码：" + String(statusCode)
                if statusCode != 0 {
                    if showfailureMsg == true {
                        failureHandle(failure: failure, stateCode: statusCode, message: error.errorDescription ?? errorCode)
                    }
                }
            }
        }
    }
    
    //错误处理 - 弹出错误信息
    static func failureHandle(failure: ((Int?, String) ->Void)? , stateCode: Int?, message: String) {
//        HMDelay(by: 0.2) {
//            if message.contains("无法连接服务器") == true {
//                //过滤掉
//                //                HMHUD.alert(type: .error, text: "1200000")
//            }else{
//                HMHUD.alert(type: .error, text: message)
//            }
//        }
//        HMHUD.alert(type: .error, text: message)
        failure?(stateCode ,message)
        
    }
    
    //登录弹窗 - 弹出是否需要登录的窗口
    static  func alertLogin(_ title: String?, code:Int) {
        //TODO: 跳转到登录页的操作：
//        HMAppDelegate.logInAccount()
//        return;
//        HMAlertActionSheetTool.showAlert( msg: title!, btn1: "取消", btn2: "确定") { (action) in
//            if action.title == "确定" {
//                IFAppPreference.user = nil
////                HMAppDelegate.enterLoginVC(animation: true)
////                                HMAppDelegate?.gotoLoginVC(animation: true)
//            }else{
//                if code == 110026{
//                    HMAccountTool.share.exitLogin()
//                }
//            }
//            
//        }
    }
    
    // 解析返回成功的数据
    static func parseSucessResponse<T: TargetType>(target: T,response:Moya.Response,success: @escaping((Data) -> Void), failure: ((Int?, String) ->Void)? ){
        // ***********  这里可以统一处理状态码 ****
        //从json中解析出status_code状态码和message，用于后面的处理
      
        guard let model = try? JSONDecoder().decode(BaseModel.self, from: response.data) else {
            //解析出错后，直接返回data
            if response.statusCode == 200 {
                do {
//                    let jsonData =   try JSONSerialization.jsonObject(with: response.data as Data, options: .mutableContainers) as! Dictionary<String, Any>
//                    let dataRes = jsonData["data"] as Any;
//                    guard  let jsonDataData = try? JSONSerialization.data(withJSONObject: dataRes, options: []) else{
//                        return
//                    }
                    success(response.data)
                    print(response.data)
                } catch {
                    print(error)
                }
            } else {
                failure?(response.statusCode, "\(response.statusCode)")
            }
            return
        }
        
        if model.success {
//            SaveFiles.save(path: target.path, data: jsonDataData)
           success(response.data)
        }else{
            failureHandle(failure: failure, stateCode: model.generalCode, message: model.error)

        }
        
        /*

        //状态码：后台会规定数据正确的状态码，未登录的状态码等，可以统一处理。
        switch (model.generalCode) {
        case HttpCode.success.rawValue :
            //数据返回正确
            do {
                let jsonData =   try JSONSerialization.jsonObject(with: response.data as Data, options: .mutableContainers) as! Dictionary<String, Any>
                let dataRes = jsonData["data"] as Any;
                
            
                if JSONSerialization.isValidJSONObject(dataRes) {
                    guard  let jsonDataData = try? JSONSerialization.data(withJSONObject: dataRes, options: [.prettyPrinted]) else{
                        return
                    }
                     SaveFiles.save(path: target.path, data: jsonDataData)
                    success(jsonDataData)
                }else{
                    print(dataRes)
                    
                    if let _ = dataRes as? String  {
                        let jsonString = dataRes as! String;
                        let jsonData:Data = jsonString.data(using: .utf8)!
                        success(jsonData)
                        SaveFiles.save(path: target.path, data: jsonData)

                    }else if let jsonNum = dataRes as? Int{
                        let jsonString = "\(jsonNum)";
                        let jsonData:Data = jsonString.data(using: .utf8)!
                        success(jsonData)
                        SaveFiles.save(path: target.path, data: jsonData)

                    }else{
                        success(response.data)
                        SaveFiles.save(path: target.path, data: response.data)

                    }


                }
                
               
            } catch {
                print(error)
                failure?(model.generalCode ,model.generalMessage)

            }
        case HttpCode.needLogin.rawValue:
            //请重新登录
            failure?(model.generalCode ,model.generalMessage)
            alertLogin(model.generalMessage,code: HttpCode.needLogin.rawValue)
        case HttpCode.tokenInvate.rawValue:
            //请重新登录
            failure?(model.generalCode ,model.generalMessage)
            alertLogin(model.generalMessage,code: HttpCode.tokenInvate.rawValue)
        default:
            //其他错误
            failureHandle(failure: failure, stateCode: model.generalCode, message: model.generalMessage)
        }
         */
    }
    

    
    static func uploadData<T: TargetType>(target:T,processCallback:((Double) -> Void)? = nil, success: @escaping((Data) -> Void), failure: ((Int?,String)->Void)? = nil ) {
        let provider = MoyaProvider<T>(plugins: [
            RequestHandlingPlugin(),
            //            networkLoggerPlugin
        ])
//        HMHUD.show("图片上传中",canTouch: false)
        provider.request(target, progress: { (process) in
            guard let processBlock = processCallback else{
                return
            }
            print("上传进度\(process.progress)")
            processBlock(process.progress)
            
        }) { (result) in
            switch result {
            case .failure:
                print("上传失败")
            case let .success(response):
                print("上传成功")
                parseSucessResponse(target: target, response: response, success: success, failure: failure)
                
            }
        }
    }
    
}
// swiftlint:enable all
