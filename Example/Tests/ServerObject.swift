//
//  ServerObject.swift
//  Eson
//
//  Created by Elliot Schrock on 2/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Eson

open class ServerObject: NSObject, EsonKeyMapper {
    open var objectId = 0
    open var createdAt = Date()
    
    open static func esonPropertyNameToKeyMap() -> [String : String] {
        return ["objectId":"id"]
    }
}
