//
//  AAExportAccountTool.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/12/19.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import DcCore

struct OutPutModel:Codable{
    var user:DcEnteredLoginParam
    var key:String
}

class AAExportAccountTool: NSObject {
    private var imexObserver: NSObjectProtocol?
    var uuidFolder:String = ""
    var outputModel:OutPutModel?

    private var dcContext: DcContext!
    internal let dcAccounts: DcAccounts!
    
    var currentVC:UIViewController?
    
    init(dcAccounts: DcAccounts,currentVC:UIViewController) {
        self.dcContext = dcAccounts.getSelected()
        self.dcAccounts = dcAccounts
        self.currentVC = currentVC;
  
        super.init()
        
        imexObserver = NotificationCenter.default.addObserver(forName: Event.importExportProgress, object: nil, queue: nil) { [weak self] notification in
            self?.handleImportExportProgress(notification)
        }
    }
    
    @objc private func handleImportExportProgress(_ notification: Notification) {
        guard let ui = notification.userInfo, let permille = ui["progress"] as? Int else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            var statusLineText: String?
            var hideQrCode = false

            if permille == 0 {
        
            } else if permille < 1000 {
                let percent: Int = permille/10
                statusLineText = String.localized("transferring") + " \(percent)%"
                hideQrCode = true
            } else if permille == 1000 {
            
                statusLineText = String.localized("done") + " 😀"
                
                let path = "\(DocumentManager.getDocumentDirectoryString())/\(self.uuidFolder)"
                
                let url = URL(fileURLWithPath: path)
                
               let allFileURLs =  DocumentManager.getAllFilesInDirectory(at: url)
                
                print("allFileURLs:\(allFileURLs)")
                
                let keyPath = allFileURLs.first { url in
                    return url.path.contains("private-key") == true
                }
                
                guard let keyPath = keyPath else { return  }
                
                let data = try?Data.init(contentsOf: keyPath)
                
                guard let data = data else { return  }
                
                
                let privateKeyText = String(data: data, encoding: .utf8)
                
                print("privateKeyText:\(privateKeyText)")
                
                self.outputModel?.key = privateKeyText ?? ""

                if let accountModel = self.outputModel {
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    
                    let jsonData = try? encoder.encode(accountModel)
                    if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8),let base64String = jsonString.data(using: .utf8)?.base64EncodedString() {
                        

                        print("base64String:\(base64String)")
                   
                        // 假设你有一个String对象，你想将其复制到剪贴板
                        
                        let vc = ShareAccountInfoQRCodeVC.init(dcContext: self.dcContext, dcAccounts: self.dcAccounts,qrCode: base64String)
//                        vc.qrCode = base64String
                        self.currentVC?.navigationController?.pushViewController(vc, animated: true)
//                        let textToCopy = base64String
//                        // 获取系统剪贴板
//                        let pasteboard = UIPasteboard.general
//                        // 将文本设置到剪贴板
//                        pasteboard.string = textToCopy
                        self.dcAccounts.startIo()
                        
//                        ProgressHUD.succeed("导出成功",delay: 3)
                    }
                    self.outputModel = nil

                   
                }
               
            }

            if let statusLineText = statusLineText {
                
                print("statusLineText:\(statusLineText)")
            }

       
        }
    }

    
     func exportAccountInfo() {
       let server = self.dcContext.getConfig("mail_server")
        let mailuser = self.dcContext.getConfig("mail_user")
        let mailpw = self.dcContext.getConfig("mail_pw")
        let mailport = self.dcContext.getConfig("mail_port")
        let mailsecurity = self.dcContext.getConfig("mail_security")
        
        let sendserver = self.dcContext.getConfig("send_server")
        let senduser = self.dcContext.getConfig("send_user")
        let sendpw = self.dcContext.getConfig("send_pw")
        let sendport = self.dcContext.getConfig("send_port")
        
        let sendsecurity = self.dcContext.getConfig("send_security")
        
        let serverflags = self.dcContext.getConfig("server_flags")
        
        let certificateChecks = self.dcContext.getConfig("imap_certificate_checks")


        let addr = self.dcContext.getConfig("addr")
        
        if let addr = addr,let mailpw = mailpw  {
            var dcLoginParm = DcEnteredLoginParam(addr: addr, password: mailpw)
            dcLoginParm.certificateChecks = certificateChecks
            dcLoginParm.imapPort = Int(mailport ?? "")
            dcLoginParm.imapSecurity = mailsecurity
            dcLoginParm.imapServer = server
            dcLoginParm.imapUser = mailuser
            
            dcLoginParm.smtpPassword = sendpw
            dcLoginParm.smtpPort = Int(sendport ?? "")

            dcLoginParm.smtpSecurity = sendsecurity
            dcLoginParm.smtpServer = sendserver
            dcLoginParm.smtpUser = senduser


            do {
                
                self.uuidFolder = UUID().uuidString;
                let outModel = OutPutModel.init(user: dcLoginParm, key: "12345")
                
                self.outputModel = outModel;
                
                let idName = self.dcContext.id
                let path = "\(DocumentManager.getDocumentDirectoryString())/\(self.uuidFolder)"
                self.dcAccounts.stopIo()
                self.dcContext.imex(what: DC_IMEX_EXPORT_SELF_KEYS, directory:path )
                
                
             
        
            } catch {
                print(error)
            }

        }

  
    }

    
}
