//
//  LoginResponse.swift
//  deltachat-ios
//
//  Created by Gongyonghui on 2025/11/7.
//  Copyright © 2025 merlinux GmbH. All rights reserved.
//

import UIKit

struct LoginResponse: Codable {
    var error:String

    var account:String
    var success:Bool
    
}
