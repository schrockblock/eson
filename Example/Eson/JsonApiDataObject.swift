//
//  JsonApiDataObject.swift
//  Eson
//
//  Created by Elliot Schrock on 5/23/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

open class JsonApiDataObject<T: NSObject>: NSObject {
    open var attributes: T?
    
    open class func generateDataObject(_ attributes: T?) -> JsonApiDataObject<T> {
        let jsonApiObject = JsonApiDataObject<T>()
        jsonApiObject.attributes = attributes
        return jsonApiObject
    }
}
