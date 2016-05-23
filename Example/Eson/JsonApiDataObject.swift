//
//  JsonApiDataObject.swift
//  Eson
//
//  Created by Elliot Schrock on 5/23/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class JsonApiDataObject<T: NSObject>: NSObject {
    public var attributes: T?
    
    public class func generateDataObject(attributes: T?) -> JsonApiDataObject<T> {
        let jsonApiObject = JsonApiDataObject<T>()
        jsonApiObject.attributes = attributes
        return jsonApiObject
    }
}
