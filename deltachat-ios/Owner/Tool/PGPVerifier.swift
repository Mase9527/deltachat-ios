import ObjectivePGP

class PGPVerifier {
    
    /// 校验密钥中的邮箱是否与输入邮箱一致
    /// - Parameters:
    ///   - email: 输入的待验证邮箱
    ///   - keyString: PGP 密钥字符串 (Armored 格式)
    /// - Returns: 是否匹配成功
    static func verifyEmail(_ email: String, inKey keyString: String) -> Bool {
        // 1. 将字符串转换为 Data
        guard let keyData = keyString.data(using: .utf8) else { return false }
        let targetEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        do {
            
            let ke = Key.init(secretKey: nil,publicKey: nil)
            // 2. 解析密钥（支持公钥或私钥）
            let keys = try ObjectivePGP.readKeys(from: keyData)
            
            for key in keys {
                
                // 3. 在 ObjectivePGP 中，User ID 信息通常存储在 packets 数组里
                                // 寻找类型为 .userID 的数据包
                         
                                
                                // 4. 备选方案：如果是较新版本，可以直接访问 keychain 或特定的属性
                                // 有些版本是通过导出为描述文本进行简单匹配
                                let keyDescription = key.description.lowercased()
                
                let userID = key.secretKey?.primaryUser?.userID ?? ""
                print("keyDescription:\(keyDescription) userID:\(userID)")
                if isEmail(targetEmail, matchingIn: userID) {
                                           return true
                    }
                
                // 3. 遍历该密钥关联的所有 User ID
//                for user in key.users {
//                    if let userID = user.userID {
//                        // 4. 提取 User ID 中的邮箱部分
//                        // UserID 格式通常为: "YourName <email@example.com>"
//                        if isEmail(email, matchingIn: userID) {
//                            return true
//                        }
//                    }
//                }
            }
        } catch {
            print("解析 PGP 密钥失败: \(error)")
            return false
        }
        
        return false
    }
    
    /// 提取并比对邮箱逻辑
    private static func isEmail(_ targetEmail: String, matchingIn userID: String) -> Bool {
        let lowercaseTarget = targetEmail.lowercased().trimmingCharacters(in: .whitespaces)
        
        // 简单判断：如果 UserID 包含 "<email>"
        if userID.lowercased().contains("<\(lowercaseTarget)>") {
            return true
        }
        
        // 容错判断：如果 UserID 直接就是邮箱格式
        if userID.lowercased().trimmingCharacters(in: .whitespaces) == lowercaseTarget {
            return true
        }
        
        return false
    }
}
