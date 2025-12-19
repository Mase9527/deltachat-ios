//
//  AALoginAccountTool.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/12/19.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import DcCore

class AALoginAccountTool: NSObject {
    private var dcContext: DcContext!
    internal let dcAccounts: DcAccounts!
    
    var loginParam:DcEnteredLoginParam?
    
    var progressAlertHandler: ProgressAlertHandler!
    
    var currentVC:UIViewController?

    init(dcAccounts: DcAccounts,currentVC:UIViewController) {
        self.dcContext = dcAccounts.getSelected()
        self.dcAccounts = dcAccounts
        self.currentVC = currentVC
        
   
        
        super.init()
        
//        imexObserver = NotificationCenter.default.addObserver(forName: Event.importExportProgress, object: nil, queue: nil) { [weak self] notification in
//            self?.handleImportExportProgress(notification)
//        }
    }
    
    func importPasteBase64(){
        let pasteboard = UIPasteboard.general
        
        if let pasteboardString = pasteboard.string {
            
            
            
            //            progressAlertHandler.showProgressAlert(title: String.localized("add_account"), dcContext: dcContext)
            
            print("剪切板内容: \(pasteboardString)")
            
            let base64String = pasteboardString
            guard let decodedData = Data(base64Encoded: base64String) else {
                print("解码失败")
                DispatchQueue.main.async {
                    ProgressHUD.failed("base64解码失败",delay: 2)
                    //                    self.progressAlertHandler.updateProgressAlert(error: "base64解码失败")
                }
                return
            }
            let decodedString = String(data: decodedData, encoding: .utf8)
            
            print("解码成功")
            
            guard let decodedString = decodedString else {
                print("解码失败")
                DispatchQueue.main.async {
                    ProgressHUD.failed("decodedString失败",delay: 2)
                    
                    //                    self.progressAlertHandler.updateProgressAlert(error: "base64 decodedString 解码失败")
                }
                return  }
            
            
            print(decodedString) // 输出：😃
            
            let jsonString = decodedString
            
            if let data = jsonString.data(using: .utf8) {
                let decoder = JSONDecoder()
                do {
                    let accounInfo = try decoder.decode(DCBase64AccountModel.self, from: data)
                    print(accounInfo)  // 输出：User(name: "John Doe", age: 30, email: "john.doe@example.com")
                    
                    
                    if dcContext.isConfigured() {
                        let accountId = dcContext.id
                        _ = dcAccounts.remove(id: accountId)
                        KeychainManager.deleteAccountSecret(id: accountId)
                        _ = dcAccounts.add()
                    }else{
                        //                        let newID = self.dcAccounts.add()
                        
                    }
                    dcContext = dcAccounts.getSelected()
                    
                    /// 导入私钥
                    let keyName = "ID:\(dcContext.id)->testKey.asc"
                    DocumentManager.createTextFile(named: keyName, content: accounInfo.key)
                    let path = DocumentManager.getDocumentDirectoryString()+"/"+keyName
                    self.dcContext.imex(what: DC_IMEX_IMPORT_SELF_KEYS, directory: path)
                    let loginParam = accounInfo.user
                    
                    self.loginParam = loginParam;
                    
                    
                    
                    self.acceptAndCreateButtonPressed()
            
                    
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                    DispatchQueue.main.async {
                        self.progressAlertHandler.updateProgressAlert(error: error.localizedDescription)
                    }
                    
                }
            }
            
            
        } else {
            print("剪切板为空")
        }
        
        
    }

    func importPasteBase64FromQRCode(qrCode:String){
        let pasteboardString = qrCode
        
        
        
        print("剪切板内容: \(pasteboardString)")
        
        let base64String = pasteboardString
        guard let decodedData = Data(base64Encoded: base64String) else {
            print("解码失败")
            DispatchQueue.main.async {
                ProgressHUD.failed("base64解码失败",delay: 2)
                //                    self.progressAlertHandler.updateProgressAlert(error: "base64解码失败")
            }
            return
        }
        let decodedString = String(data: decodedData, encoding: .utf8)
        
        print("解码成功")
        
        guard let decodedString = decodedString else {
            print("解码失败")
            DispatchQueue.main.async {
                ProgressHUD.failed("decodedString失败",delay: 2)
                
                //                    self.progressAlertHandler.updateProgressAlert(error: "base64 decodedString 解码失败")
            }
            return  }
        
        
        print(decodedString) // 输出：😃
        
        let jsonString = decodedString
        
        if let data = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let accounInfo = try decoder.decode(DCBase64AccountModel.self, from: data)
                print(accounInfo)  // 输出：User(name: "John Doe", age: 30, email: "john.doe@example.com")
                
                
                if dcContext.isConfigured() {
                    let accountId = dcContext.id
                    _ = dcAccounts.remove(id: accountId)
                    KeychainManager.deleteAccountSecret(id: accountId)
                    _ = dcAccounts.add()
                }else{
                    //                        let newID = self.dcAccounts.add()
                    
                }
                dcContext = dcAccounts.getSelected()
                
                /// 导入私钥
                let keyName = "ID:\(dcContext.id)->testKey.asc"
                DocumentManager.createTextFile(named: keyName, content: accounInfo.key)
                let path = DocumentManager.getDocumentDirectoryString()+"/"+keyName
                self.dcContext.imex(what: DC_IMEX_IMPORT_SELF_KEYS, directory: path)
                let loginParam = accounInfo.user
                
                self.loginParam = loginParam;
                
                
                
                self.acceptAndCreateButtonPressed()
                //                    do {
                //                        _ = try self.dcContext.addOrUpdateTransport(param: loginParam)
                //                    } catch {
                //                    }
                
                
                
            } catch {
                print("Error decoding JSON: \(error)")
                DispatchQueue.main.async {
                    self.progressAlertHandler.updateProgressAlert(error: error.localizedDescription)
                }
                
            }
        }
        
        
        
        
        
    }
    
    // MARK: - action: configuration
    @objc private func acceptAndCreateButtonPressed() {
        let progressAlertHandler = ProgressAlertHandler(notification: Event.configurationProgress, onSuccess: { [weak self] in
            self?.handleCreateSuccess()
        })
        progressAlertHandler.dataSource = self.currentVC
        progressAlertHandler.showProgressAlert(title: String.localized("add_account"), dcContext: self.dcContext)
        
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            do {
                
                guard let loginParam = self.loginParam else { return  }
                
                _ = try self.dcContext.addOrUpdateTransport(param: loginParam)
                
            } catch {
                DispatchQueue.main.async {
                    progressAlertHandler.updateProgressAlert(error: error.localizedDescription)
                }
            }
            
        }
        
        self.progressAlertHandler = progressAlertHandler
    }

    private func handleCreateSuccess() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.registerForNotifications()
            appDelegate.reloadDcContext()
            appDelegate.prepopulateWidget()
        }
    }
}
