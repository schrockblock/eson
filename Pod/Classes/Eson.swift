//
//  Eson.swift
//  Pods
//
//  Created by Elliot Schrock on 1/25/16.
//
//

import UIKit

public class Eson: NSObject {
    var transformers: [Transformer]? = [Transformer]()
    
    public override init() {
        self.transformers?.append(StringTransformer())
        self.transformers?.append(IntTransformer())
    }
    
    public func toJsonDictionary(object: AnyObject) -> [String: AnyObject]? {
        var json = [String: AnyObject]()
        
        let mirror = Mirror(reflecting: object)
        
        var children = [(label: String?, value: Any)]()
        let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children)!
        children += mirrorChildrenCollection
        
        var currentMirror = mirror
        while let superclassChildren = currentMirror.superclassMirror()?.children {
            let randomCollection = AnyRandomAccessCollection(superclassChildren)!
            children += randomCollection
            currentMirror = currentMirror.superclassMirror()!
        }
        
        for (optionalPropertyName, value) in children {
            let propertyName = optionalPropertyName!
            let propertyValue = value as? AnyObject
            
            var isTransformed = false
            for transformer in self.transformers! {
                if propertyValue!.dynamicType === transformer.exampleValue().dynamicType {
                    json[convertToSnakeCase(propertyName)] = transformer.objectForValue(value as? AnyObject)
                    isTransformed = true
                    break;
                }
            }
            if !isTransformed {
                json[convertToSnakeCase(propertyName)] = toJsonDictionary((value as? AnyObject)!)
            }
        }
        return json
    }
    
    public func fromJsonDictionary<T: NSObject>(jsonDictionary: [String: AnyObject]?, clazz: T.Type) -> T? {
        let object = clazz.init()
        if let json = jsonDictionary {
            for key: String in json.keys{
                let camelCaseKey = convertToCamelCase(key)
                if object.respondsToSelector(Selector(camelCaseKey)) {
                    object.setValue(json[key], forKey: camelCaseKey)
                }
            }
        }
        return object
    }
    
    public func toJsonArray(array: [AnyObject]?) -> [NSDictionary]? {
        return nil
    }
    
    public func fromJsonArray() -> [AnyObject]? {
        return nil
    }
    
    //MARK: non-public methods
    
    func convertToCamelCase(string: String) -> String {
        let stringArray = string.characters.split("_")
        let capStringArray = stringArray.map{String($0).capitalizedString}
        var camelCaseString = capStringArray.joinWithSeparator("")
        camelCaseString = camelCaseString.characters.first.map {String($0).lowercaseString}! + camelCaseString.substringFromIndex(camelCaseString.startIndex.successor())
        return camelCaseString
    }
    
    func convertToSnakeCase(string: String) -> String {
        var snakeCaseString = string
        while let range = snakeCaseString.rangeOfCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet()) {
            let substring = snakeCaseString.substringWithRange(range)
            snakeCaseString.replaceRange(range, with: "_\(substring.lowercaseString)")
        }
        return snakeCaseString
    }
}

public protocol Transformer {
    func objectForValue(value: AnyObject?) -> AnyObject?;
    func exampleValue() -> AnyObject;
}

public class IntTransformer: Transformer {
    public func objectForValue(value: AnyObject?) -> AnyObject? {
        return value
    }
    public func exampleValue() -> AnyObject {
        return Int()
    }
}

public class StringTransformer: Transformer {
    public func objectForValue(value: AnyObject?) -> AnyObject? {
        return value
    }
    public func exampleValue() -> AnyObject {
        return String()
    }
}

public class ArrayTransformer: Transformer {
    public func objectForValue(value: AnyObject?) -> AnyObject? {
        return Eson().toJsonArray(value as? [AnyObject])
    }
    public func exampleValue() -> AnyObject {
        return [AnyObject]()
    }
}
