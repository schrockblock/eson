//
//  JsonApiDataObject.swift
//  Eson
//
//  Created by Elliot Schrock on 5/23/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Eson

open class JsonApiDataObject<T: NSObject>: NSObject, EsonKeyMapper {
    open var attributesDictionary: Dictionary<String, AnyObject>? = nil {
        didSet {
            attributes = Eson().fromJsonDictionary(attributesDictionary, clazz: T.self)
        }
    }
    open var attributes: T?
    
    public static func esonPropertyNameToKeyMap() -> [String : String] {
        return ["attributesDictionary": "attributes"]
    }
    
    open class func generateDataObject(_ attributes: T?) -> JsonApiDataObject<T> {
        let jsonApiObject = JsonApiDataObject<T>()
        jsonApiObject.attributes = attributes
        return jsonApiObject
    }
}
