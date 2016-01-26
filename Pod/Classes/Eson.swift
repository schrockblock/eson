//
//  Eson.swift
//  Pods
//
//  Created by Elliot Schrock on 1/25/16.
//
//

import UIKit

public class Eson: NSObject {
    
    public func toJsonDictionary(object: AnyObject?) -> AnyObject? {
        
        return nil
    }
    
    public func fromJsonDictionary<T: NSObject>(jsonDictionary: [String: AnyObject]?, clazz: T.Type) -> T? {
        let object = clazz.init()
        if let json = jsonDictionary {
            for key: String in json.keys{
                if object.respondsToSelector("name") {
                    object.setValue(json[key], forKey: key)
                }
            }
        }
        return object
    }
    
    func convertToCamelCase(string: String) -> String {
        return (string.characters.split("_")).map{String($0).capitalizedString}.joinWithSeparator("")
    }
    
    public func toJsonArray() -> [NSDictionary]? {
        return nil
    }
    
    public func fromJsonArray() -> [AnyObject]? {
        return nil
    }
}
