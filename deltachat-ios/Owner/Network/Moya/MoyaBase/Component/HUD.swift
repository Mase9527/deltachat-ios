//  弹窗提示
import Foundation

//class Alert: NSObject {
//    enum AlertType {
//        case success
//        case info
//        case error
//        case warning
//    }
//    
//    class func show(type: AlertType, text: String) {
//        if let window = UIApplication.shared.delegate?.window {
//            var image: UIImage
//            switch type {
//            case .success:
//                image = #imageLiteral(resourceName: "Alert_success")
//            case .info:
//                image = #imageLiteral(resourceName: "Alert_info")
//            case .error:
//                image = #imageLiteral(resourceName: "Alert_error")
//            case .warning:
//                image = #imageLiteral(resourceName: "Alert_warning")
//            }
//            let hud = MBProgressHUD.showAdded(to: window!, animated: true)
//            hud.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
//            hud.mode = .customView
//            hud.customView = UIImageView(image:image)
//            hud.label.text = text
//            hud.hide(animated: true, afterDelay: 1.2)
//        }
//    }
//}
//
//
