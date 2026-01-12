//
//  BindRecoveryModel.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2026/1/12.
//  Copyright © 2026 merlinux GmbH. All rights reserved.
//

import UIKit


struct RequestTokenModel: Codable {
    var error:String
    var token:String
    var success:Bool
    
}


struct VerifyModel: Codable {
    var error:String
    var success:Bool
    
}

struct RecoveryEmailModel: Codable {
    var error:String
    var main_email:String
    var recovery_email:String
    var success:Bool
    
}




