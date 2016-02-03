//
//  Eson.swift
//  Pods
//
//  Created by Elliot Schrock on 1/25/16.
//
//

import UIKit

public class Eson: NSObject {
    public var serializers: [Serializer]! = [Serializer]()
    public var deserializers: [Deserializer]! = [Deserializer]()
    
    public override init() {
        self.serializers?.append(StringSerializer())
        self.serializers?.append(IntSerializer())
        self.serializers?.append(BoolSerializer())
    }
    
    public func toJsonDictionary(object: AnyObject) -> [String: AnyObject]? {
        var json = [String: AnyObject]()
        
        var keyMap = [String:String]()
        if object.dynamicType.respondsToSelector(Selector("esonPropertyNameToKeyMap")) {
            keyMap = (object.dynamicType as! EsonKeyMapper.Type).esonPropertyNameToKeyMap()
        }
        
        let children = childrenOfClass(object)
        for child in children {
            let propertyName = child.label!
            var value = child.value as? AnyObject
            let subMirror = Mirror(reflecting: child.value)
            var hasAValue: Bool = true
            if subMirror.displayStyle == .Optional {
                if subMirror.children.count == 0 {
                    hasAValue = false
                }else{
                    value = subMirror.children.first!.value as? AnyObject
                }
            }
            
            if hasAValue {
                let propertyValue = value!
                var isSerialized = false
                for serializer in self.serializers {
                    if propertyValue.dynamicType === serializer.exampleValue().dynamicType {
                        var key = convertToSnakeCase(propertyName)
                        if let mappedKey = keyMap[propertyName] {
                            key = mappedKey
                        }
                        json[key] = serializer.objectForValue(propertyValue)
                        isSerialized = true
                        break;
                    }
                }
                if !isSerialized {
                    json[convertToSnakeCase(propertyName)] = toJsonDictionary(propertyValue)
                }
            }
        }
        return json
    }
    
    public func fromJsonDictionary<T: NSObject>(jsonDictionary: [String: AnyObject]?, clazz: T.Type) -> T? {
        let object = clazz.init()
        var keyMap = [String:String]()
        if object.dynamicType.respondsToSelector(Selector("esonPropertyNameToKeyMap")) {
            keyMap = (object.dynamicType as! EsonKeyMapper.Type).esonPropertyNameToKeyMap()
        }
        if let json = jsonDictionary {
            for key: String in json.keys{
                var propertyKey = convertToCamelCase(key)
                for propertyName in keyMap.keys {
                    if keyMap[propertyName] == key {
                        propertyKey = propertyName
                    }
                }
                if object.respondsToSelector(Selector(propertyKey)) {
                    let propertyClassName = propertyTypeStringForName(object, name: propertyKey)!
                    var isDeserialized = false
                    for deserializer in self.deserializers! {
                        let nameOfClass = deserializer.nameOfClass()
                        if propertyClassName == nameOfClass {
                            isDeserialized = true
                            object.setValue(deserializer.valueForObject(json[key]!), forKey: propertyKey)
                        }
                    }
                    if !isDeserialized {
                        object.setValue(json[key], forKey: propertyKey)
                    }
                }
            }
        }
        return object
    }
    
    public func toJsonArray(array: [AnyObject]?) -> [[String: AnyObject]]? {
        var result = [[String: AnyObject]]()
        if let objectArray = array {
            for object in objectArray {
                result.append(toJsonDictionary(object)!)
            }
        }
        return result
    }
    
    public func fromJsonArray<T: NSObject>(array: [[String: AnyObject]]?, clazz: T.Type) -> [AnyObject]? {
        var result = [AnyObject]()
        if let jsonArray = array {
            for json in jsonArray {
                result.append(fromJsonDictionary(json, clazz: clazz)!)
            }
        }
        return result
    }
    
    //MARK: non-public methods
    
    func childrenOfClass(object: AnyObject) -> [(label: String?, value: Any)] {
        let mirror = Mirror(reflecting: object)
        
        var children = [(label: String?, value: Any)]()
        let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children)!
        children += mirrorChildrenCollection
        
        var currentMirror = mirror
        while let superclassChildren = currentMirror.superclassMirror()?.children {
            let randomCollection = AnyRandomAccessCollection(superclassChildren)
            if let collection = randomCollection {
                children += collection
            }
            currentMirror = currentMirror.superclassMirror()!
        }
        
        return children
    }
    
    func propertyTypeStringForName(object: NSObject, name: String) -> String? {
        var propertyType: String?
        let children = childrenOfClass(object)

        for child in children {
            let propertyName = child.label!
            if propertyName == name {
                propertyType = unwrappedClassName(String(child.value.dynamicType))
            }
        }
        return propertyType
    }
    
    func unwrappedClassName(string: String?) -> String? {
        var unwrappedClassName: String? = string
        if string?.characters.count > 9 {
            if string?.substringToIndex((string?.startIndex.advancedBy(9))!) == "Optional<" {
                unwrappedClassName = string?.substringToIndex((string?.startIndex.advancedBy((string?.characters.count)! - 1))!)
                unwrappedClassName = unwrappedClassName?.substringFromIndex((unwrappedClassName?.startIndex.advancedBy(9))!)
            }
        }
        return unwrappedClassName
    }
    
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

public protocol EsonKeyMapper {
    static func esonPropertyNameToKeyMap() -> [String:String];
}

public protocol Deserializer {
    func nameOfClass() -> String;
    func valueForObject(object: AnyObject) -> AnyObject?;
}

public protocol Serializer {
    func objectForValue(value: AnyObject?) -> AnyObject?;
    func exampleValue() -> AnyObject;
}

public class IntSerializer: Serializer {
    public func objectForValue(value: AnyObject?) -> AnyObject? {
        return value
    }
    public func exampleValue() -> AnyObject {
        return Int()
    }
}

public class BoolSerializer: Serializer {
    public func objectForValue(value: AnyObject?) -> AnyObject? {
        return value
    }
    public func exampleValue() -> AnyObject {
        return Bool()
    }
}

public class StringSerializer: Serializer {
    public func objectForValue(value: AnyObject?) -> AnyObject? {
        return value
    }
    public func exampleValue() -> AnyObject {
        return String()
    }
}

//extension NSObject{
//    func getTypeOfProperty(name: String) -> String? {
//        let mirror: Mirror = Mirror(reflecting:self)
//        
//        for child in mirror.children {
//            if child.label! == name {
//                return String(child.value.dynamicType)
//            }
//        }
//        return nil
//    }
//}
