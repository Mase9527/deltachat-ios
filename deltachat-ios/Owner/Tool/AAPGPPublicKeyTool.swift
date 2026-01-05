//
//  AAPGPPublicKeyTool.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/12/24.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
//import ObjectivePGP

class AAPGPPublicKeyTool: NSObject {
  static  func generatePGPPublicKey(mail:String) -> String? {
      

        
        return ""
    }
    
    
    

}

/*
 
 
 
 DispatchQueue.main.async(execute: DispatchWorkItem.init(block: {
     if response.success == true && response.account.isEmpty == false {
         ProgressHUD.dismiss()

         
         
         let privateKeyText = self.dcContext.createKeypair(email: address)
          logger.error("key:\(privateKeyText)")
         
         
         let testVC = AAPublicKeyPopupViewController(key: privateKeyText)
         
         testVC.copySucessAction = {
             
             
             let domain = "aa1234.com"

             let address = "\(self.accountTextField.text ?? "")@\(domain)"
             
             let loginVC = AALoginViewController(mail:address , password:self.pwdTextField.text ?? "" ,nickName:self.nameTextField.text ?? "AAMail" ,dcContext: self.dcContext,dcAccounts: self.dcAccounts)
      
             self.navigationController?.pushViewController(loginVC, animated: true)
         }
       self.present(testVC, animated: true)
         

         self.dcContext = self.dcAccounts.getSelected()
         
         if let avatorimage = self.avatorimage {
             AvatarHelper.saveSelfAvatarImage(dcContext: self.dcContext, image: avatorimage)

         }


//                          self.acceptOwnewAndCreateButtonPressed()
         
     }else if response.error.isEmpty == false && response.success == false{
         ProgressHUD.failed("\(response.error)",delay: 3)
     }else{
         ProgressHUD.failed("登录失败",delay: 3)

     }
 }))

 */
