//
//  AAPGPPublicKeyTool.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/12/24.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import ObjectivePGP

class AAPGPPublicKeyTool: NSObject {
  static  func generatePGPPublicKey(mail:String) -> String? {
      
      let keyGender = KeyGenerator()
//      keyGender.curveKind = .curveEd25519
//      keyGender.keyAlgorithm = .elgamal;
//      keyGender.cipherAlgorithm = .AES128
//      keyGender.hashAlgorithm = .SHA256
      
      
      let key = keyGender.generate(for: mail, passphrase: nil)
        let publicKey = try? key.export(keyType: .public)
        let secretKey = try? key.export(keyType: .secret)
        
        // 假设你已经有了 secretKey (Data)
        if let secretKeyData = try? key.export(keyType: .secret) {
            
            // 使用 Armor 类进行 ASCII 铠装编码
            let armoredSecretKey = Armor.armored(secretKeyData, as: .secretKey)
            
            print("你的私钥字符串：\n\(armoredSecretKey)")
        }
        
        
        return ""
    }
    
    
    

}
