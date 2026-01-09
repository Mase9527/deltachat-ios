//
//  LegacyQRCodeScanner.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/8.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit
import CoreImage

class LegacyQRCodeScanner {
    
    /// 使用 Core Image 识别二维码（兼容旧版本 iOS）
    static func detectQRCodeWithCoreImage(from image: UIImage) -> [String] {
        // 1. 将 UIImage 转换为 CIImage
        guard let ciImage = CIImage(image: image) else {
            return []
        }
        
        // 2. 创建二维码检测器
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                       context: nil,
                                       options: [
                                        CIDetectorAccuracy: CIDetectorAccuracyHigh
                                       ]) else {
            return []
        }
        
        // 3. 检测二维码特征
        let features = detector.features(in: ciImage)
        
        // 4. 提取二维码内容
        var qrCodeStrings: [String] = []
        
        for case let feature as CIQRCodeFeature in features {
            if let messageString = feature.messageString {
                qrCodeStrings.append(messageString)
            }
        }
        
        return qrCodeStrings
    }
    
    /// 获取二维码位置信息
    static func detectQRCodeWithPosition(from image: UIImage) -> [QRCodePosition] {
        guard let ciImage = CIImage(image: image),
              let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                       context: nil,
                                       options: [
                                        CIDetectorAccuracy: CIDetectorAccuracyHigh
                                       ]) else {
            return []
        }
        
        let features = detector.features(in: ciImage)
        
        return features.compactMap { feature in
            guard let qrFeature = feature as? CIQRCodeFeature,
                  let message = qrFeature.messageString else {
                return nil
            }
            
            return QRCodePosition(
                content: message,
                topLeft: qrFeature.topLeft,
                topRight: qrFeature.topRight,
                bottomLeft: qrFeature.bottomLeft,
                bottomRight: qrFeature.bottomRight
            )
        }
    }
}

// MARK: - 数据结构

struct QRCodePosition {
    let content: String
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    
    /// 获取二维码的边界矩形
    var boundingRect: CGRect {
        let minX = min(topLeft.x, bottomLeft.x)
        let minY = min(topLeft.y, topRight.y)
        let maxX = max(topRight.x, bottomRight.x)
        let maxY = max(bottomLeft.y, bottomRight.y)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    /// 判断点是否在二维码区域内
    func contains(point: CGPoint) -> Bool {
        return boundingRect.contains(point)
    }
}
