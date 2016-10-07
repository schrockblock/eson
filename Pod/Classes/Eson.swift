//
//  Eson.swift
//  Pods
//
//  Created by Elliot Schrock on 1/25/16.
//
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class Eson: NSObject {
    open var serializers: [Serializer]! = [Serializer]()
    open var deserializers: [Deserializer]! = [Deserializer]()
    
    public override init() {
        self.serializers?.append(IntSerializer())
        self.serializers?.append(BoolSerializer())
    }
    
    open func toJsonDictionary(_ object: AnyObject) -> [String: AnyObject]? {
        var json = [String: AnyObject]()
        
        var keyMap = [String:String]()
        if type(of: object).responds(to: Selector(("esonPropertyNameToKeyMap"))) {
            keyMap = (type(of: object) as! EsonKeyMapper.Type).esonPropertyNameToKeyMap()
        }
        
        let children = childrenOfClass(object)
        for child in children {
            let propertyName = child.label!
            var value = child.value as? AnyObject
            let subMirror = Mirror(reflecting: child.value)
            var hasAValue: Bool = true
            if subMirror.displayStyle == .optional {
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
                    if type(of: propertyValue) === type(of: serializer.exampleValue()) {
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
                    //There are SO MANY types of strings whose dynamicType does NOT equal String().dynamicType,
                    //so, I'm just outright testing for it here
                    if propertyValue is String {
                        json[convertToSnakeCase(propertyName)] = propertyValue
                    }else{
                        json[convertToSnakeCase(propertyName)] = toJsonDictionary(propertyValue) as AnyObject?
                    }
                }
            }
        }
        return json
    }
    
    open func fromJsonDictionary<T: NSObject>(_ jsonDictionary: [String: AnyObject]?, clazz: T.Type) -> T? {
        let object = clazz.init()
        var keyMap = [String:String]()
        if type(of: object).responds(to: Selector(("esonPropertyNameToKeyMap"))) {
            keyMap = (type(of: object) as! EsonKeyMapper.Type).esonPropertyNameToKeyMap()
        }
        if let json = jsonDictionary {
            for key: String in json.keys{
                var propertyKey = convertToCamelCase(key)
                for propertyName in keyMap.keys {
                    if keyMap[propertyName] == key {
                        propertyKey = propertyName
                        break;
                    }
                }
                if object.responds(to: Selector(propertyKey)) {
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
                        if let jsonValue = json[key] {
                            if jsonValue.isKind(of: NSDictionary.self) {
                                var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
                                appName = appName.replacingOccurrences(of: " ", with: "_")
                                let classStringName = "_TtC\(appName.characters.count)\(appName)\(propertyClassName.characters.count)\(propertyClassName)"
                                if let propertyType = NSClassFromString(classStringName) as? NSObject.Type {
                                    object.setValue(fromJsonDictionary(json[key] as? [String: AnyObject], clazz: propertyType), forKey: propertyKey)
                                }else{
                                    object.setValue(json[key], forKey: propertyKey)
                                }
                            }else if !(json[key] is NSNull) {
                                object.setValue(json[key], forKey: propertyKey)
                            }
                        }
                    }
                }
            }
        }
        return object
    }
    
    open func toJsonArray(_ array: [AnyObject]?) -> [[String: AnyObject]]? {
        var result = [[String: AnyObject]]()
        if let objectArray = array {
            for object in objectArray {
                result.append(toJsonDictionary(object)!)
            }
        }
        return result
    }
    
    open func fromJsonArray<T: NSObject>(_ array: [[String: AnyObject]]?, clazz: T.Type) -> [T]? {
        var result = [T]()
        if let jsonArray = array {
            for json in jsonArray {
                result.append(fromJsonDictionary(json, clazz: clazz)!)
            }
        }
        return result
    }
    
    //MARK: non-public methods
    
    func childrenOfClass(_ object: AnyObject) -> [(label: String?, value: Any)] {
        let mirror = Mirror(reflecting: object)
        
        var children = [(label: String?, value: Any)]()
        let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children)!
        children += mirrorChildrenCollection
        
        var currentMirror = mirror
        while let superclassChildren = currentMirror.superclassMirror?.children {
            let randomCollection = AnyRandomAccessCollection(superclassChildren)
            if let collection = randomCollection {
                children += collection
            }
            currentMirror = currentMirror.superclassMirror!
        }
        
        return children
    }
    
//    func propertyTypeForName(object: NSObject, name: String) -> AnyObject.Type? {
//        var propertyType: AnyObject.Type?
//        let children = childrenOfClass(object)
//        
//        for child in children {
//            let propertyName = child.label!
//            if propertyName == name {
//                propertyType = child.value.dynamicType
//            }
//        }
//        return propertyType
//    }
    
    func propertyTypeStringForName(_ object: NSObject, name: String) -> String? {
        var propertyType: String?
        let children = childrenOfClass(object)

        for child in children {
            let propertyName = child.label!
            if propertyName == name {
                propertyType = unwrappedClassName(String(describing: type(of: (child.value) as AnyObject)))
            }
        }
        return propertyType
    }
    
    func unwrappedClassName(_ string: String?) -> String? {
        var unwrappedClassName: String? = string
        if string?.characters.count > 9 {
            if (string?.substring(to: (string?.characters.index((string?.startIndex)!, offsetBy: 9))!))! == "Optional<" {
                unwrappedClassName = string?.substring(to: (string?.characters.index((string?.startIndex)!, offsetBy: (string?.characters.count)! - 1))!)
                unwrappedClassName = unwrappedClassName?.substring(from: (unwrappedClassName?.characters.index((unwrappedClassName?.startIndex)!, offsetBy: 9))!)
            }
        }
        return unwrappedClassName
    }
    
    func convertToCamelCase(_ string: String) -> String {
        let stringArray = string.characters.split(separator: "_")
        let capStringArray = stringArray.map{String($0).capitalized}
        var camelCaseString = capStringArray.joined(separator: "")
        camelCaseString = camelCaseString.characters.first.map {String($0).lowercased()}! + camelCaseString.substring(from: camelCaseString.characters.index(after: camelCaseString.startIndex))
        return camelCaseString
    }
    
    func convertToSnakeCase(_ string: String) -> String {
        var snakeCaseString = string
        while let range = snakeCaseString.rangeOfCharacter(from: CharacterSet.uppercaseLetters) {
            let substring = snakeCaseString.substring(with: range)
            snakeCaseString.replaceSubrange(range, with: "_\(substring.lowercased())")
        }
        return snakeCaseString
    }
}

public protocol EsonKeyMapper {
    static func esonPropertyNameToKeyMap() -> [String:String];
}

public protocol Deserializer {
    func nameOfClass() -> String;
    func valueForObject(_ object: AnyObject) -> AnyObject?;
}

public protocol Serializer {
    func objectForValue(_ value: AnyObject?) -> AnyObject?;
    func exampleValue() -> AnyObject;
}

open class IntSerializer: Serializer {
    open func objectForValue(_ value: AnyObject?) -> AnyObject? {
        return value
    }
    open func exampleValue() -> AnyObject {
        return Int() as AnyObject
    }
}

open class BoolSerializer: Serializer {
    open func objectForValue(_ value: AnyObject?) -> AnyObject? {
        return value
    }
    open func exampleValue() -> AnyObject {
        return Bool() as AnyObject
    }
}

//public class StringSerializer: Serializer {
//    public func objectForValue(value: AnyObject?) -> AnyObject? {
//        return value
//    }
//    public func exampleValue() -> AnyObject {
//        return String()
//    }
//}

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
