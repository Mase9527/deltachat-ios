import UIKit
import CoreImage

class AdvancedQRCodeGenerator {
    
    // MARK: - 配置结构体
    struct QRCodeConfig {
        let size: CGSize
        let correctionLevel: String
        let foregroundColor: UIColor
        let backgroundColor: UIColor
        let logo: UIImage?
        let logoSize: CGSize
        
        init(
            size: CGSize = CGSize(width: 200, height: 200),
            correctionLevel: String = "H",
            foregroundColor: UIColor = .black,
            backgroundColor: UIColor = .white,
            logo: UIImage? = nil,
            logoSize: CGSize = CGSize(width: 40, height: 40)
        ) {
            self.size = size
            self.correctionLevel = correctionLevel
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
            self.logo = logo
            self.logoSize = logoSize
        }
    }
    
    // MARK: - 生成方法
    
    /// 生成二维码（完整配置）
    static func generateQRCode(
        from string: String,
        config: QRCodeConfig = QRCodeConfig()
    ) -> UIImage? {
        
        // 1. 生成基础二维码
        guard let baseQRCode = generateBaseQRCode(from: string, correctionLevel: config.correctionLevel) else {
            return nil
        }
        
        // 2. 缩放二维码
        let scaledQRCode = scaleImage(baseQRCode, to: config.size)
        
        // 3. 应用颜色
        guard let coloredQRCode = applyColor(
            to: scaledQRCode,
            foreground: config.foregroundColor,
            background: config.backgroundColor
        ) else {
            return nil
        }
        
        // 4. 添加 Logo（如果有）
        if let logo = config.logo {
            return addLogo(to: coloredQRCode, logo: logo, logoSize: config.logoSize)
        }
        
        return coloredQRCode
    }
    
    // MARK: - 私有方法
    
    private static func generateBaseQRCode(from string: String, correctionLevel: String) -> CIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        
        return filter.outputImage
    }
    
    private static func scaleImage(_ image: CIImage, to size: CGSize) -> CIImage {
        let scaleX = size.width / image.extent.size.width
        let scaleY = size.height / image.extent.size.height
        return image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
    
    private static func applyColor(to image: CIImage, foreground: UIColor, background: UIColor) -> UIImage? {
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        colorFilter.setValue(image, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: foreground), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: background), forKey: "inputColor1")
        
        guard let coloredImage = colorFilter.outputImage else { return nil }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(coloredImage, from: coloredImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    private static func addLogo(to image: UIImage, logo: UIImage, logoSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        // 绘制二维码
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        // 计算 Logo 位置
        let logoX = (image.size.width - logoSize.width) / 2
        let logoY = (image.size.height - logoSize.height) / 2
        let logoRect = CGRect(x: logoX, y: logoY, width: logoSize.width, height: logoSize.height)
        
        // 绘制 Logo
        logo.draw(in: logoRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

//// 使用示例
//let config = AdvancedQRCodeGenerator.QRCodeConfig(
//    size: CGSize(width: 300, height: 300),
//    correctionLevel: "H",
//    foregroundColor: .systemBlue,
//    backgroundColor: .white,
//    logo: UIImage(named: "app_logo"),
//    logoSize: CGSize(width: 60, height: 60)
//)
//
//let qrCode = AdvancedQRCodeGenerator.generateQRCode(from: "自定义内容", config: config)
