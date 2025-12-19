//
//  DeltaChatLinkConverter.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/11/17.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit

import Foundation

struct DeltaChatLink {
    
    
    let fingerprint: String
    let address: String?
    let name: String?
    let invitationId: String?
    let secret: String?
    
    // MARK: - 从 Delta Chat URL 初始化
    init?(fromDeltaChatURL urlString: String) {
        guard let url = URL(string: urlString),
              let fragment = url.fragment else {
            return nil
        }
        
        let components = fragment.components(separatedBy: "&")
        
        // 第一个组件是指纹
        guard let firstComponent = components.first else {
            return nil
        }
        self.fingerprint = firstComponent.uppercased()
        
        // 解析其他参数
        var address: String?
        var name: String?
        var invitationId: String?
        var secret: String?
        
        for component in components.dropFirst() {
            let keyValue = component.components(separatedBy: "=")
            guard keyValue.count == 2 else { continue }
            
            let key = keyValue[0]
            let value = keyValue[1]
            
            switch key {
            case "a":
                address = value
            case "n":
                name = value.isEmpty ? nil : value
            case "i":
                invitationId = value
            case "s":
                secret = value
            default:
                break
            }
        }
        
        self.address = address
        self.name = name
        self.invitationId = invitationId
        self.secret = secret
    }
    
    // MARK: - 从 OPENPGP4FPR 格式初始化
    init?(fromOpenPGP4FPR openPGP4FPR: String) {
        // 移除 OPENPGP4FPR: 前缀
        guard openPGP4FPR.hasPrefix("OPENPGP4FPR:") else {
            return nil
        }
        
        var withoutPrefix = String(openPGP4FPR.dropFirst("OPENPGP4FPR:".count))
        
         withoutPrefix = withoutPrefix.replacingOccurrences(of: "%23", with: "#")

        // 分割指纹和参数
        let parts = withoutPrefix.components(separatedBy: "#")
        guard parts.count == 2 else {
            return nil
        }
        
        let fingerprint = parts[0]
        let parametersString = parts[1]
        
        self.fingerprint = fingerprint.uppercased()
        
        // 解析参数
        var address: String?
        var name: String?
        var invitationId: String?
        var secret: String?
        
        let parameters = parametersString.components(separatedBy: "&")
        for parameter in parameters {
            let keyValue = parameter.components(separatedBy: "=")
            guard keyValue.count == 2 else { continue }
            
            let key = keyValue[0]
            let value = keyValue[1]
            
            switch key {
            case "a":
                address = value
            case "n":
                name = value.isEmpty ? nil : value
            case "i":
                invitationId = value
            case "s":
                secret = value
            default:
                break
            }
        }
        
        self.address = address
        self.name = name
        self.invitationId = invitationId
        self.secret = secret
    }
    
    // MARK: - 转换为 OPENPGP4FPR 格式
    var openPGP4FPR: String {
        var components: [String] = []
        
        if let address = address {
            components.append("a=\(address)")
        }
        if let name = name {
            components.append("n=\(name)")
        } else {
            components.append("n=") // 保持空名称
        }
        if let invitationId = invitationId {
            components.append("i=\(invitationId)")
        }
        if let secret = secret {
            components.append("s=\(secret)")
        }
        
        let parametersString = components.joined(separator: "&")
        let str = "OPENPGP4FPR:\(fingerprint)#\(parametersString)"
        return str
    }
    
    // MARK: - 转换为 Delta Chat URL 格式
    var deltaChatURL: String {
        var components: [String] = [fingerprint]
        
        if let address = address {
            components.append("a=\(address)")
        }
        if let name = name {
            components.append("n=\(name)")
        } else {
            components.append("n=")
        }
        if let invitationId = invitationId {
            components.append("i=\(invitationId)")
        }
        if let secret = secret {
            components.append("s=\(secret)")
        }
        
        let fragment = components.joined(separator: "&")
        return "https://i.delta.chat/#\(fragment)"
    }
}


class DeltaChatLinkConverter {
    static let scheme = "OPENPGP4FPR:"
    // MARK: - Delta Chat URL 转 OPENPGP4FPR
    static func deltaChatToOpenPGP4FPR(_ deltaChatURL: String) -> String? {
        guard let link = DeltaChatLink(fromDeltaChatURL: deltaChatURL) else {
            return nil
        }
        return link.openPGP4FPR
    }
    
    // MARK: - OPENPGP4FPR 转 Delta Chat URL
    static func openPGP4FPRToDeltaChat(_ openPGP4FPR: String) -> String? {
        guard let link = DeltaChatLink(fromOpenPGP4FPR: openPGP4FPR) else {
            return nil
        }
        return link.deltaChatURL
    }
    
    // MARK: - 批量转换
    static func batchConvertDeltaChatToOpenPGP4FPR(_ urls: [String]) -> [String: String] {
        var results: [String: String] = [:]
        
        for url in urls {
            if let converted = deltaChatToOpenPGP4FPR(url) {
                results[url] = converted
            }
        }
        
        return results
    }
    
    static func batchConvertOpenPGP4FPRToDeltaChat(_ openPGP4FPRs: [String]) -> [String: String] {
        var results: [String: String] = [:]
        
        for openPGP4FPR in openPGP4FPRs {
            if let converted = openPGP4FPRToDeltaChat(openPGP4FPR) {
                results[openPGP4FPR] = converted
            }
        }
        
        return results
    }
}
