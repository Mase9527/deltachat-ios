//
//  GroupAvatarGenerator.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/6.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit

import UIKit

// MARK: - 群聊头像工具类
class GroupAvatarGenerator {
    
    // MARK: - 配置
    struct Config {
        var size: CGSize = CGSize(width: 200, height: 200)
        var cornerRadius: CGFloat = 10
        var borderWidth: CGFloat = 2
        var borderColor: UIColor = .white
        var backgroundColor: UIColor = .systemGray6
        var textColor: UIColor = .white
        var font: UIFont = .boldSystemFont(ofSize: 20)
        var spacing: CGFloat = 2 // 头像之间的间距
        var showBorder: Bool = true
        var placeholderColor: UIColor = .systemBlue
        var placeholderTextColor: UIColor = .white
        var placeholderFont: UIFont = .systemFont(ofSize: 14)
    }
    
    // MARK: - 头像数据模型
    struct AvatarInfo {
        var image: UIImage?
        var placeholderText: String? // 当没有图片时显示的文本
        var backgroundColor: UIColor? // 自定义背景色
        var textColor: UIColor? // 自定义文字颜色
    }
    
    // MARK: - 生成群聊头像
    static func generateGroupAvatar(
        avatars: [AvatarInfo],
        config: Config = Config()
    ) -> UIImage? {
        guard !avatars.isEmpty else { return nil }
        
        let count = avatars.count
        
        // 根据头像数量选择布局
        switch count {
        case 1:
            return generateSingleAvatar(avatar: avatars[0], config: config)
        case 2:
            return generateTwoAvatars(avatars: avatars, config: config)
        case 3:
            return generateThreeAvatars(avatars: avatars, config: config)
        case 4:
            return generateFourAvatars(avatars: avatars, config: config)
        case 5:
            return generateFiveAvatars(avatars: avatars, config: config)
        case 6...9:
            return generateMultipleAvatars(avatars: avatars, config: config)
        default:
            return generateComplexAvatars(avatars: avatars, config: config)
        }
    }
    
    // MARK: - 单个头像
    private static func generateSingleAvatar(
        avatar: AvatarInfo,
        config: Config
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: config.size)
        
        // 绘制背景
        config.backgroundColor.setFill()
        context.fill(rect)
        
        // 绘制头像或占位符
        let avatarRect = rect.insetBy(dx: config.borderWidth, dy: config.borderWidth)
        drawAvatar(avatar, in: avatarRect, config: config, context: context)
        
        // 绘制边框
        if config.showBorder {
            context.setStrokeColor(config.borderColor.cgColor)
            context.setLineWidth(config.borderWidth)
            context.stroke(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - 两个头像
    private static func generateTwoAvatars(
        avatars: [AvatarInfo],
        config: Config
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: config.size)
        
        // 绘制背景
        config.backgroundColor.setFill()
        context.fill(rect)
        
        // 计算头像大小和位置
        let avatarSize = CGSize(
            width: (config.size.width - config.spacing) / 2,
            height: config.size.height
        )
        
        let leftRect = CGRect(
            x: config.borderWidth,
            y: config.borderWidth,
            width: avatarSize.width - config.spacing - config.borderWidth,
            height: avatarSize.height - 2 * config.borderWidth
        )
        
        let rightRect = CGRect(
            x: avatarSize.width + config.spacing,
            y: config.borderWidth,
            width: avatarSize.width - config.spacing - config.borderWidth,
            height: avatarSize.height - 2 * config.borderWidth
        )
        
        // 绘制左侧头像
        if avatars.count > 0 {
            drawAvatar(avatars[0], in: leftRect, config: config, context: context)
        }
        
        // 绘制右侧头像
        if avatars.count > 1 {
            drawAvatar(avatars[1], in: rightRect, config: config, context: context)
        }
        
        // 绘制边框
        if config.showBorder {
            context.setStrokeColor(config.borderColor.cgColor)
            context.setLineWidth(config.borderWidth)
            context.stroke(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - 三个头像
    private static func generateThreeAvatars(
        avatars: [AvatarInfo],
        config: Config
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: config.size)
        
        // 绘制背景
        config.backgroundColor.setFill()
        context.fill(rect)
        
        // 计算头像大小和位置
        let topAvatarSize = CGSize(
            width: config.size.width,
            height: (config.size.height - config.spacing) / 2
        )
        
        let bottomAvatarSize = CGSize(
            width: (config.size.width - config.spacing) / 2,
            height: (config.size.height - config.spacing) / 2
        )
        
        let topRect = CGRect(
            x: config.borderWidth,
            y: config.borderWidth,
            width: config.size.width - 2 * config.borderWidth,
            height: topAvatarSize.height - config.spacing - config.borderWidth
        )
        
        let bottomLeftRect = CGRect(
            x: config.borderWidth,
            y: topAvatarSize.height + config.spacing,
            width: bottomAvatarSize.width - config.spacing - config.borderWidth,
            height: bottomAvatarSize.height - 2 * config.borderWidth
        )
        
        let bottomRightRect = CGRect(
            x: bottomAvatarSize.width + config.spacing,
            y: topAvatarSize.height + config.spacing,
            width: bottomAvatarSize.width - config.spacing - config.borderWidth,
            height: bottomAvatarSize.height - 2 * config.borderWidth
        )
        
        // 绘制顶部头像
        if avatars.count > 0 {
            drawAvatar(avatars[0], in: topRect, config: config, context: context)
        }
        
        // 绘制左下头像
        if avatars.count > 1 {
            drawAvatar(avatars[1], in: bottomLeftRect, config: config, context: context)
        }
        
        // 绘制右下头像
        if avatars.count > 2 {
            drawAvatar(avatars[2], in: bottomRightRect, config: config, context: context)
        }
        
        // 绘制边框
        if config.showBorder {
            context.setStrokeColor(config.borderColor.cgColor)
            context.setLineWidth(config.borderWidth)
            context.stroke(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - 四个头像
    private static func generateFourAvatars(
        avatars: [AvatarInfo],
        config: Config
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: config.size)
        
        // 绘制背景
        config.backgroundColor.setFill()
        context.fill(rect)
        
        // 计算头像大小和位置
        let avatarSize = CGSize(
            width: (config.size.width - config.spacing) / 2,
            height: (config.size.height - config.spacing) / 2
        )
        
        let topLeftRect = CGRect(
            x: config.borderWidth,
            y: config.borderWidth,
            width: avatarSize.width - config.spacing - config.borderWidth,
            height: avatarSize.height - config.spacing - config.borderWidth
        )
        
        let topRightRect = CGRect(
            x: avatarSize.width + config.spacing,
            y: config.borderWidth,
            width: avatarSize.width - config.spacing - config.borderWidth,
            height: avatarSize.height - config.spacing - config.borderWidth
        )
        
        let bottomLeftRect = CGRect(
            x: config.borderWidth,
            y: avatarSize.height + config.spacing,
            width: avatarSize.width - config.spacing - config.borderWidth,
            height: avatarSize.height - config.spacing - config.borderWidth
        )
        
        let bottomRightRect = CGRect(
            x: avatarSize.width + config.spacing,
            y: avatarSize.height + config.spacing,
            width: avatarSize.width - config.spacing - config.borderWidth,
            height: avatarSize.height - config.spacing - config.borderWidth
        )
        
        // 绘制四个头像
        for i in 0..<min(4, avatars.count) {
            let rect: CGRect
            switch i {
            case 0: rect = topLeftRect
            case 1: rect = topRightRect
            case 2: rect = bottomLeftRect
            case 3: rect = bottomRightRect
            default: continue
            }
            drawAvatar(avatars[i], in: rect, config: config, context: context)
        }
        
        // 绘制边框
        if config.showBorder {
            context.setStrokeColor(config.borderColor.cgColor)
            context.setLineWidth(config.borderWidth)
            context.stroke(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - 五个头像
    private static func generateFiveAvatars(
        avatars: [AvatarInfo],
        config: Config
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: config.size)
        
        // 绘制背景
        config.backgroundColor.setFill()
        context.fill(rect)
        
        // 计算头像大小和位置
        let topAvatarSize = CGSize(
            width: (config.size.width - 2 * config.spacing) / 3,
            height: (config.size.height - config.spacing) / 2
        )
        
        let bottomAvatarSize = CGSize(
            width: (config.size.width - config.spacing) / 2,
            height: (config.size.height - config.spacing) / 2
        )
        
        // 顶部三个头像
        let topRects = [
            CGRect(
                x: config.borderWidth,
                y: config.borderWidth,
                width: topAvatarSize.width - config.spacing - config.borderWidth,
                height: topAvatarSize.height - config.spacing - config.borderWidth
            ),
            CGRect(
                x: topAvatarSize.width + config.spacing,
                y: config.borderWidth,
                width: topAvatarSize.width - config.spacing - config.borderWidth,
                height: topAvatarSize.height - config.spacing - config.borderWidth
            ),
            CGRect(
                x: 2 * topAvatarSize.width + 2 * config.spacing,
                y: config.borderWidth,
                width: topAvatarSize.width - config.spacing - config.borderWidth,
                height: topAvatarSize.height - config.spacing - config.borderWidth
            )
        ]
        
        // 底部两个头像
        let bottomLeftRect = CGRect(
            x: config.borderWidth,
            y: topAvatarSize.height + config.spacing,
            width: bottomAvatarSize.width - config.spacing - config.borderWidth,
            height: bottomAvatarSize.height - 2 * config.borderWidth
        )
        
        let bottomRightRect = CGRect(
            x: bottomAvatarSize.width + config.spacing,
            y: topAvatarSize.height + config.spacing,
            width: bottomAvatarSize.width - config.spacing - config.borderWidth,
            height: bottomAvatarSize.height - 2 * config.borderWidth
        )
        
        // 绘制顶部三个头像
        for i in 0..<min(3, avatars.count) {
            drawAvatar(avatars[i], in: topRects[i], config: config, context: context)
        }
        
        // 绘制底部两个头像
        if avatars.count > 3 {
            drawAvatar(avatars[3], in: bottomLeftRect, config: config, context: context)
        }
        
        if avatars.count > 4 {
            drawAvatar(avatars[4], in: bottomRightRect, config: config, context: context)
        }
        
        // 绘制边框
        if config.showBorder {
            context.setStrokeColor(config.borderColor.cgColor)
            context.setLineWidth(config.borderWidth)
            context.stroke(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - 6-9个头像
    private static func generateMultipleAvatars(
        avatars: [AvatarInfo],
        config: Config
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: config.size)
        
        // 绘制背景
        config.backgroundColor.setFill()
        context.fill(rect)
        
        // 计算行列数（3x3网格）
        let rows = 3
        let columns = 3
        let spacing = config.spacing
        
        let cellWidth = (config.size.width - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
        let cellHeight = (config.size.height - (CGFloat(rows - 1) * spacing)) / CGFloat(rows)
        
        // 绘制每个头像
        for i in 0..<min(9, avatars.count) {
            let row = i / columns
            let column = i % columns
            
            let x = CGFloat(column) * (cellWidth + spacing)
            let y = CGFloat(row) * (cellHeight + spacing)
            
            let avatarRect = CGRect(
                x: x + config.borderWidth,
                y: y + config.borderWidth,
                width: cellWidth - 2 * config.borderWidth,
                height: cellHeight - 2 * config.borderWidth
            )
            
            drawAvatar(avatars[i], in: avatarRect, config: config, context: context)
        }
        
        // 绘制边框
        if config.showBorder {
            context.setStrokeColor(config.borderColor.cgColor)
            context.setLineWidth(config.borderWidth)
            context.stroke(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - 超过9个头像的复杂布局
    private static func generateComplexAvatars(
        avatars: [AvatarInfo],
        config: Config
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: config.size)
        
        // 绘制背景
        config.backgroundColor.setFill()
        context.fill(rect)
        
        // 显示前8个头像，最后一个位置显示+剩余数量
        let maxDisplayCount = 8
        let displayAvatars = Array(avatars.prefix(maxDisplayCount))
        let remainingCount = avatars.count - maxDisplayCount
        
        // 使用4x4网格显示
        let rows = 4
        let columns = 4
        let spacing = config.spacing
        
        let cellWidth = (config.size.width - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
        let cellHeight = (config.size.height - (CGFloat(rows - 1) * spacing)) / CGFloat(rows)
        
        // 绘制前8个头像
        for i in 0..<min(maxDisplayCount, displayAvatars.count) {
            let row = i / (columns / 2)
            let column = i % (columns / 2)
            
            // 居中显示
            let x = CGFloat(column) * (cellWidth * 2 + spacing) + cellWidth / 2
            let y = CGFloat(row) * (cellHeight * 2 + spacing) + cellHeight / 2
            
            let avatarRect = CGRect(
                x: x + config.borderWidth,
                y: y + config.borderWidth,
                width: cellWidth * 1.5 - 2 * config.borderWidth,
                height: cellHeight * 1.5 - 2 * config.borderWidth
            )
            
            drawAvatar(displayAvatars[i], in: avatarRect, config: config, context: context)
        }
        
        // 在最后一个位置显示+剩余数量
        if remainingCount > 0 {
            let lastRow = 3
            let lastColumn = 3
            
            let x = CGFloat(lastColumn) * (cellWidth + spacing)
            let y = CGFloat(lastRow) * (cellHeight + spacing)
            
            let plusRect = CGRect(
                x: x + config.borderWidth,
                y: y + config.borderWidth,
                width: cellWidth - 2 * config.borderWidth,
                height: cellHeight - 2 * config.borderWidth
            )
            
            // 绘制+背景
            let backgroundColor = config.placeholderColor
            backgroundColor.setFill()
            let path = UIBezierPath(roundedRect: plusRect, cornerRadius: config.cornerRadius)
            path.fill()
            
            // 绘制+文字
            let text = "+\(remainingCount)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: config.placeholderFont,
                .foregroundColor: config.placeholderTextColor
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: plusRect.midX - textSize.width / 2,
                y: plusRect.midY - textSize.height / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        // 绘制边框
        if config.showBorder {
            context.setStrokeColor(config.borderColor.cgColor)
            context.setLineWidth(config.borderWidth)
            context.stroke(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - 绘制单个头像（图片或文本）
    private static func drawAvatar(
        _ avatar: AvatarInfo,
        in rect: CGRect,
        config: Config,
        context: CGContext
    ) {
        context.saveGState()
        
        // 创建圆形路径
        let path = UIBezierPath(roundedRect: rect, cornerRadius: config.cornerRadius)
        path.addClip()
        
        if let image = avatar.image {
            // 绘制图片
            image.draw(in: rect)
        } else {
            // 绘制占位符
            let bgColor = avatar.backgroundColor ?? config.placeholderColor
            let textColor = avatar.textColor ?? config.placeholderTextColor
            
            // 绘制背景
            bgColor.setFill()
            path.fill()
            
            // 如果有占位文本，绘制文本
            if let placeholderText = avatar.placeholderText {
                let text = String(placeholderText.prefix(1)).uppercased()
                let font = config.placeholderFont
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: textColor
                ]
                
                let textSize = text.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: rect.midX - textSize.width / 2,
                    y: rect.midY - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                text.draw(in: textRect, withAttributes: attributes)
            }
        }
        
        context.restoreGState()
    }
}

// MARK: - 便捷扩展
extension GroupAvatarGenerator {
    
    // MARK: - 从图片URL生成群聊头像（异步）
    static func generateGroupAvatar(
        imageURLs: [String],
        config: Config = Config(),
        completion: @escaping (UIImage?) -> Void
    ) {
        // 使用缓存提高性能
        let cache = NSCache<NSString, UIImage>()
        
        DispatchQueue.global().async {
            var avatarInfos: [AvatarInfo] = []
            let group = DispatchGroup()
            
            for (index, urlString) in imageURLs.enumerated() {
                guard let url = URL(string: urlString) else {
                    avatarInfos.append(AvatarInfo(placeholderText: "\(index + 1)"))
                    continue
                }
                
                group.enter()
                
                // 检查缓存
                if let cachedImage = cache.object(forKey: urlString as NSString) {
                    avatarInfos.append(AvatarInfo(image: cachedImage))
                    group.leave()
                } else {
                    // 下载图片
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            cache.setObject(image, forKey: urlString as NSString)
                            avatarInfos.append(AvatarInfo(image: image))
                        } else {
                            avatarInfos.append(AvatarInfo(placeholderText: "\(index + 1)"))
                        }
                        group.leave()
                    }.resume()
                }
            }
            
            group.wait()
            
            // 生成群聊头像
            let groupAvatar = generateGroupAvatar(avatars: avatarInfos, config: config)
            
            DispatchQueue.main.async {
                completion(groupAvatar)
            }
        }
    }
    
    // MARK: - 从图片生成群聊头像（同步）
    static func generateGroupAvatar(
        images: [UIImage],
        config: Config = Config()
    ) -> UIImage? {
        let avatarInfos = images.map { AvatarInfo(image: $0) }
        return generateGroupAvatar(avatars: avatarInfos, config: config)
    }
    
    // MARK: - 从名字生成群聊头像
    static func generateGroupAvatar(
        names: [String],
        config: Config = Config()
    ) -> UIImage? {
        let avatarInfos = names.map { name -> AvatarInfo in
            let firstChar = String(name.prefix(1)).uppercased()
            
            // 为不同名字生成不同背景色
            let colors: [UIColor] = [
                .systemRed, .systemBlue, .systemGreen, .systemOrange,
                .systemPurple, .systemPink, .systemTeal, .systemIndigo
            ]
            let colorIndex = abs(name.hash) % colors.count
            let bgColor = colors[colorIndex]
            
            return AvatarInfo(
                placeholderText: firstChar,
                backgroundColor: bgColor,
                textColor: .white
            )
        }
        
        return generateGroupAvatar(avatars: avatarInfos, config: config)
    }
    
    // MARK: - 生成渐变群聊头像
    static func generateGradientGroupAvatar(
        count: Int,
        gradientColors: [UIColor] = [.systemBlue, .systemPurple],
        config: Config = Config()
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(config.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: config.size)
        
        // 创建渐变
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = gradientColors.map { $0.cgColor } as CFArray
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil) else {
            return nil
        }
        
        // 绘制渐变背景
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: config.size.width, y: config.size.height)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        
        // 绘制头像数量
        let text = "\(count)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: config.font.withSize(config.size.width * 0.3),
            .foregroundColor: config.textColor
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (config.size.width - textSize.width) / 2,
            y: (config.size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        // 绘制边框
        if config.showBorder {
            context.setStrokeColor(config.borderColor.cgColor)
            context.setLineWidth(config.borderWidth)
            context.stroke(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: - UIView扩展，方便直接使用
extension UIImageView {
    
    /// 设置群聊头像
    /// - Parameters:
    ///   - avatars: 头像信息数组
    ///   - config: 配置项
    func setGroupAvatar(_ avatars: [GroupAvatarGenerator.AvatarInfo], config: GroupAvatarGenerator.Config = .init()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let groupAvatar = GroupAvatarGenerator.generateGroupAvatar(avatars: avatars, config: config)
            
            DispatchQueue.main.async {
                self.image = groupAvatar
            }
        }
    }
    
    /// 从URL数组设置群聊头像
    /// - Parameters:
    ///   - imageURLs: 图片URL数组
    ///   - config: 配置项
    ///   - placeholder: 占位图
    func setGroupAvatar(
        imageURLs: [String],
        config: GroupAvatarGenerator.Config = .init(),
        placeholder: UIImage? = nil
    ) {
        self.image = placeholder
        
        GroupAvatarGenerator.generateGroupAvatar(imageURLs: imageURLs, config: config) { [weak self] image in
            self?.image = image
        }
    }
    
    /// 从名字数组设置群聊头像
    /// - Parameters:
    ///   - names: 名字数组
    ///   - config: 配置项
    func setGroupAvatar(names: [String], config: GroupAvatarGenerator.Config = .init()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let groupAvatar = GroupAvatarGenerator.generateGroupAvatar(names: names, config: config)
            
            DispatchQueue.main.async {
                self.image = groupAvatar
            }
        }
    }
}

// MARK: - 预定义样式
extension GroupAvatarGenerator.Config {
    
    /// 微信样式配置
    static var wechatStyle: GroupAvatarGenerator.Config {
        var config = GroupAvatarGenerator.Config()
        config.cornerRadius = 4
        config.borderWidth = 0
        config.backgroundColor = .systemGray6
        config.spacing = 1
        config.showBorder = false
        return config
    }
    
    /// 圆形样式配置
    static var circleStyle: GroupAvatarGenerator.Config {
        var config = GroupAvatarGenerator.Config()
        config.cornerRadius = 200
        config.borderWidth = 2
        config.borderColor = .white
        config.backgroundColor = .systemGray6
        config.spacing = 2
        config.showBorder = true
        return config
    }
    
    /// 简洁样式配置
    static var minimalStyle: GroupAvatarGenerator.Config {
        var config = GroupAvatarGenerator.Config()
        config.cornerRadius = 0
        config.borderWidth = 0
        config.backgroundColor = .clear
        config.spacing = 0
        config.showBorder = false
        return config
    }
}

/*
struct GroupAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            GroupAvatarView(
                avatars: [
                    GroupAvatarGenerator.AvatarInfo(placeholderText: "张"),
                    GroupAvatarGenerator.AvatarInfo(placeholderText: "李")
                ],
                config: .circleStyle
            )
            
            GroupAvatarView(
                avatars: [
                    GroupAvatarGenerator.AvatarInfo(placeholderText: "A"),
                    GroupAvatarGenerator.AvatarInfo(placeholderText: "B"),
                    GroupAvatarGenerator.AvatarInfo(placeholderText: "C")
                ],
                config: .wechatStyle
            )
        }
        .padding()
    }
}

// MARK: - 性能优化工具
class GroupAvatarCache {
    static let shared = GroupAvatarCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // 缓存最多100张图片
    }
    
    func avatar(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setAvatar(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    static func cacheKey(for avatars: [GroupAvatarGenerator.AvatarInfo], config: GroupAvatarGenerator.Config) -> String {
        var key = "group_avatar_"
        
        for avatar in avatars {
            if let image = avatar.image {
                key += "\(image.hash)_"
            } else if let text = avatar.placeholderText {
                key += "\(text)_"
            }
        }
        
        key += "\(config.size.width)_\(config.size.height)_"
        key += "\(config.cornerRadius)_\(config.spacing)"
        
        return key
    }
}

// MARK: - 带缓存的扩展
extension GroupAvatarGenerator {
    static func generateCachedGroupAvatar(
        avatars: [AvatarInfo],
        config: Config = Config()
    ) -> UIImage? {
        let cacheKey = GroupAvatarCache.cacheKey(for: avatars, config: config)
        
        // 尝试从缓存获取
        if let cachedImage = GroupAvatarCache.shared.avatar(for: cacheKey) {
            return cachedImage
        }
        
        // 生成新图片
        guard let image = generateGroupAvatar(avatars: avatars, config: config) else {
            return nil
        }
        
        // 缓存图片
        GroupAvatarCache.shared.setAvatar(image, for: cacheKey)
        
        return image
    }
}

// MARK: - 测试工具
struct GroupAvatarGeneratorTests {
    static func runTests() {
        print("=== GroupAvatarGenerator 测试 ===")
        
        // 测试1-9个头像生成
        for count in 1...9 {
            let avatars = (1...count).map { _ in
                GroupAvatarGenerator.AvatarInfo(placeholderText: "测")
            }
            
            let image = GroupAvatarGenerator.generateGroupAvatar(
                avatars: avatars,
                config: .init(size: CGSize(width: 100, height: 100))
            )
            
            print("生成 \(count) 个头像: \(image != nil ? "成功" : "失败")")
        }
        
        // 测试超过9个头像
        let manyAvatars = (1...15).map { index in
            GroupAvatarGenerator.AvatarInfo(placeholderText: "\(index)")
        }
        
        let manyImage = GroupAvatarGenerator.generateGroupAvatar(
            avatars: manyAvatars,
            config: .init(size: CGSize(width: 100, height: 100))
        )
        
        print("生成 15 个头像: \(manyImage != nil ? "成功" : "失败")")
    }
}
*/
