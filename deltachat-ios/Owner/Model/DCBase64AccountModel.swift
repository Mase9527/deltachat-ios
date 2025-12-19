//
//  DCBase64AccountModel.swift
//  deltachat-ios
//
//  Created by gongyonghui on 2025/11/3.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit
import DcCore

struct DCBase64User:Codable {
    
    var addr:String
    
    var certificateChecks:String?
    var imapPort:String?
    var imapSecurity:String?
    var imapServer:String
    var imapUser:String?
    var oauth2:String?
    var password:String
    var smtpPassword:String?
    var smtpPort:String?
    var smtpSecurity:String?
    var smtpServer:String
    var smtpUser:String

}

class DCBase64AccountModel: NSObject,Codable {

    var user:DcEnteredLoginParam
    var key:String
}
