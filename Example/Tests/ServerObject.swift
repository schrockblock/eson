//
//  ServerObject.swift
//  Eson
//
//  Created by Elliot Schrock on 2/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Eson

public class ServerObject: NSObject, EsonKeyMapper {
    public var objectId = 0
    public var createdAt = NSDate()
    
    public static func esonPropertyNameToKeyMap() -> [String : String] {
        return ["objectId":"id"]
    }
}
