//
//  Eson.swift
//  Pods
//
//  Created by Elliot Schrock on 1/25/16.
//
//

import UIKit

public protocol EsonKeyMapper {
    static func esonPropertyNameToKeyMap() -> [String:String]
}

public protocol Deserializer {
    func nameOfClass() -> String
    func valueForObject(_ object: AnyObject) -> AnyObject?
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

open class ISODateDeserializer: Deserializer {
    public init() {}
    public func nameOfClass() -> String {
        return "Date"
    }
    public func valueForObject(_ object: AnyObject) -> AnyObject? {
        if let string = object as? String {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let date = formatter.date(from: string)
            return date as AnyObject
        }
        return nil
    }
}

open class Eson: NSObject {
    open var shouldConvertSnakeCase = true
    open var serializers: [Serializer]! = [Serializer]()
    open var deserializers: [Deserializer]! = [Deserializer]()
    
    public init(shouldConvertSnakeCase: Bool = true) {
        super.init()
        
        self.shouldConvertSnakeCase = shouldConvertSnakeCase
        
        self.serializers?.append(IntSerializer())
        self.serializers?.append(BoolSerializer())
    }
    
    open func toJsonDictionary(_ object: AnyObject) -> [String: AnyObject]? {
        if object is Dictionary<String, Any> {
            return object as? [String : AnyObject]
        }
        
        var json = [String: AnyObject]()
        
        var keyMap = [String:String]()
        if type(of: object).responds(to: Selector(("esonPropertyNameToKeyMap"))) {
            keyMap = (type(of: object) as! EsonKeyMapper.Type).esonPropertyNameToKeyMap()
        }
        
        let children = childrenOfClass(object)
        for child in children {
            let propertyName = child.label!
            var value = child.value as AnyObject
            let subMirror = Mirror(reflecting: child.value)
            var hasAValue: Bool = true
            if subMirror.displayStyle == .optional {
                if subMirror.children.count == 0 {
                    hasAValue = false
                }else{
                    value = subMirror.children.first!.value as AnyObject
                }
            }
            
            if hasAValue {
                let propertyValue = value
                var isSerialized = false
                for serializer in self.serializers {
                    if type(of: propertyValue) === type(of: serializer.exampleValue()) {
                        var key = shouldConvertSnakeCase ? convertToSnakeCase(propertyName) : propertyName
                        if let mappedKey = keyMap[propertyName] {
                            key = mappedKey
                        }
                        json[key] = serializer.objectForValue(propertyValue)
                        isSerialized = true
                        break;
                    }
                }
                if !isSerialized {
                    let key = shouldConvertSnakeCase ? convertToSnakeCase(propertyName) : propertyName
                    //There are SO MANY types of strings whose dynamicType does NOT equal String().dynamicType,
                    //so, I'm just outright testing for it here
                    if propertyValue is String {
                        json[key] = propertyValue
                    }else if propertyValue is NSArray {
                        json[key] = toJsonArray(propertyValue as? [AnyObject]) as AnyObject?
                    }else{
                        json[key] = toJsonDictionary(propertyValue) as AnyObject?
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
                let propertyKey = transformPropertyKey(key, keyMap)
                if object.responds(to: Selector(propertyKey)) {
                    let propertyClassName = propertyTypeStringForName(object, name: propertyKey)!
                    var isDeserialized = false
                    if let deserializer = deserializer(for: propertyClassName) {
                        isDeserialized = true
                        if json[key] is NSNull {
                            continue
                        } else {
                            if let value = deserializer.valueForObject(json[key]!), !(value is NSNull) {
                                object.setValue(value, forKey: propertyKey)
                            } else {
                                continue
                            }
                        }
                    }
                    if !isDeserialized {
                        if let jsonValue = json[key] {
                            if jsonValue.isKind(of: NSDictionary.self) {
                                handleDictionary(object: object, propertyKey: propertyKey, json: json, key: key)
                            }else if jsonValue.isKind(of: NSArray.self) {
                                handleArray(object: object, propertyKey: propertyKey, json: json, key: key)
                            }else if !(json[key] is NSNull) {
                                setValueOfObject(object, value: json[key]!, key: propertyKey)
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
            if let deserializer = deserializer(for: String(describing: T.self)) {
                result = fromJsonArray(using: deserializer, jsonArray, clazz: T.self)!
            }else{
                for json in jsonArray {
                    result.append(fromJsonDictionary(json, clazz: clazz)!)
                }
            }
        }
        return result
    }
    
    //MARK: non-public methods
    
    func fromJsonArray<T: NSObject>(using deserializer: Deserializer, _ jsonArray: [[String: AnyObject]], clazz: T.Type) -> [T]? {
        var result = [T]()
        for json in jsonArray {
            result.append(deserializer.valueForObject(json as AnyObject) as! T)
        }
        return result
    }
    
    func deserializer(for propertyClassName: String?) -> Deserializer? {
        for deserializer in self.deserializers! {
            let nameOfClass = deserializer.nameOfClass()
            if propertyClassName == nameOfClass {
                return deserializer
            }
        }
        return nil
    }
    
    func transformPropertyKey(_ key: String, _ keyMap: [String: String]) -> String {
        var propertyKey = shouldConvertSnakeCase ? convertToCamelCase(key) : key
        for propertyName in keyMap.keys {
            if keyMap[propertyName] == key {
                propertyKey = propertyName
                break;
            }
        }
        return propertyKey
    }
    
    func handleDictionary(object: NSObject, propertyKey: String, json: [String: AnyObject], key: String) {
        if let mirror = propertyMirrorFor(object, name: propertyKey) {
            var typeName: String? = String(describing: mirror.subjectType)
            if mirror.displayStyle == .optional {
                typeName = unwrappedClassName(typeName)
            }
            if typeName?.characters.count > 29 && (typeName?.substring(to: (typeName?.index((typeName?.startIndex)!, offsetBy: 29))!).contains("ImplicitlyUnwrappedOptional<"))! {
                typeName = unwrappedImplicitClassName(typeName)
            }
            
            let mirrorClass: AnyClass? = typeClass(typeName: typeName!)
            if mirrorClass == nil {
                if let isDict = typeName?.hasPrefix("Dictionary"), isDict {
                    setValueOfObject(object, value: json[key]!, key: propertyKey)
                }
            } else {
                let mirrorType: NSObject.Type = mirrorClass.self as! NSObject.Type
                if mirrorType.init() is NSDictionary {
                    setValueOfObject(object, value: json[key]!, key: propertyKey)
                }else{
                    setValueOfObject(object, value: fromJsonDictionary(json[key] as? [String: AnyObject], clazz: mirrorType)!, key: propertyKey)
                }
            }
        }else{
            setValueOfObject(object, value: json[key]!, key: propertyKey)
        }
    }
    
    func handleArray(object: NSObject, propertyKey: String, json: [String: AnyObject], key: String) {
        let array = json[key] as! NSArray
        if array.count > 0 {
            let value = array[0] as AnyObject
            if value.isKind(of: NSDictionary.self) {
                if let mirror = propertyMirrorFor(object, name: propertyKey) {
                    var typeName: String?
                    if mirror.displayStyle == .optional {
                        typeName = unwrappedClassName(String(describing: mirror.subjectType))
                        typeName = unwrappedArrayElementClassName(typeName)
                    }else{
                        typeName = unwrappedArrayElementClassName(String(describing: mirror.subjectType))
                    }
                    let mirrorClass: AnyClass? = typeClass(typeName: typeName!)
                    let mirrorType: NSObject.Type = mirrorClass.self as! NSObject.Type
                    
                    if let deserializer = deserializer(for: typeName) {
                        setValueOfObject(object, value: fromJsonArray(using: deserializer, (json[key] as? [[String: AnyObject]])!, clazz: mirrorType)! as AnyObject, key: propertyKey)
                    }else{
                        setValueOfObject(object, value: fromJsonArray(json[key] as? [[String: AnyObject]], clazz: mirrorType)! as AnyObject, key: propertyKey)
                    }
                }else{
                    setValueOfObject(object, value: json[key]!, key: propertyKey)
                }
            }
        }
    }
    
    func typeClass(typeName: String) -> AnyClass? {
        var mirrorClass: AnyClass? = NSClassFromString(typeName)
        if mirrorClass == nil {
            var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
            appName = appName.replacingOccurrences(of: " ", with: "_")
            mirrorClass = NSClassFromString(appName + "." + typeName)
        }
        return mirrorClass
    }
    
    func setValueOfObject(_ object: AnyObject, value: AnyObject, key: String) {
        if object.responds(to: Selector(key)) {
            object.setValue(value, forKey: key)
        }else{
            let ivar: Ivar = class_getInstanceVariable(type(of: object), key)
            let fieldOffset = ivar_getOffset(ivar)
            
            // Pointer arithmetic to get a pointer to the field
            let pointerToInstance = Unmanaged.passUnretained(object).toOpaque()
            
            switch value {
            case is Int:
                let pointerToField = unsafeBitCast(pointerToInstance + fieldOffset, to: UnsafeMutablePointer<Int?>.self)
                
                // Set the value using the pointer
                pointerToField.pointee = value as? Int
                break
            case is Bool:
                let pointerToField = unsafeBitCast(pointerToInstance + fieldOffset, to: UnsafeMutablePointer<Bool?>.self)
                
                // Set the value using the pointer
                pointerToField.pointee = value as? Bool
                break
            default:
                break
            }
        }
    }
    
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
    
    func propertyTypeForName(_ object: NSObject, name: String) -> Any.Type? {
        return propertyMirrorFor(object, name: name)?.subjectType
    }
    
    func propertyMirrorFor(_ object: NSObject, name: String) -> Mirror? {
        let children = childrenOfClass(object)
        
        for child in children {
            let propertyName = child.label!
            if propertyName == name {
                return Mirror(reflecting: child.value)
            }
        }
        
        return nil
    }
    
    func propertyTypeStringForName(_ object: NSObject, name: String) -> String? {
        var propertyTypeString: String? = ""
        
        if let mirror = propertyMirrorFor(object, name: name) {
            if mirror.displayStyle == .optional {
                propertyTypeString = unwrappedClassName(String(describing: mirror.subjectType))
            } else {
                propertyTypeString = String(describing: mirror.subjectType)
            }
        }
        //        let children = childrenOfClass(object)
        //
        //        for child in children {
        //            let propertyName = child.label!
        //            if propertyName == name {
        //                propertyType = unwrappedClassName(String(describing: type(of: (child.value) as AnyObject)))
        //            }
        //        }
        return propertyTypeString
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
    
    func unwrappedImplicitClassName(_ string: String?) -> String? {
        var unwrappedClassName: String? = string
        if string?.characters.count > 29 {
            if (string?.substring(to: (string?.characters.index((string?.startIndex)!, offsetBy: 28))!))! == "ImplicitlyUnwrappedOptional<" {
                unwrappedClassName = string?.substring(to: (string?.characters.index((string?.startIndex)!, offsetBy: (string?.characters.count)! - 1))!)
                unwrappedClassName = unwrappedClassName?.substring(from: (unwrappedClassName?.characters.index((unwrappedClassName?.startIndex)!, offsetBy: 28))!)
            }
        }
        return unwrappedClassName
    }
    
    func unwrappedArrayElementClassName(_ string: String?) -> String? {
        var unwrappedClassName: String? = string
        if string?.characters.count > 6 {
            if (string?.substring(to: (string?.characters.index((string?.startIndex)!, offsetBy: 6))!))! == "Array<" {
                unwrappedClassName = string?.substring(to: (string?.characters.index((string?.startIndex)!, offsetBy: (string?.characters.count)! - 1))!)
                unwrappedClassName = unwrappedClassName?.substring(from: (unwrappedClassName?.characters.index((unwrappedClassName?.startIndex)!, offsetBy: 6))!)
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
