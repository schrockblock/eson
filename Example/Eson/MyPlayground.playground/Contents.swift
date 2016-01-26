//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
class SomeBaseClass: NSObject {
    var name: String? = "bob"
    class func printClassName() {
        print("SomeBaseClass")
    }
    required override init() {
        
    }
    func printName(){
        print("hi" + name!)
    }
}
class SomeSubClass: SomeBaseClass {
    override class func printClassName() {
        print("SomeSubClass")
    }
}
let someInstance: SomeBaseClass = SomeSubClass()
// The compile-time type of someInstance is SomeBaseClass,
// and the runtime type of someInstance is SomeBaseClass
someInstance.dynamicType.printClassName()
// prints "SomeSubClass"
someInstance.printName()

func fromJsonDictionary<T: NSObject>(jsonDictionary: [String: AnyObject]?, clazz: T.Type) -> T? {
    let object = clazz.init()
    object.valueForKey("name")
    object.respondsToSelector(Selector("name"))
    if let json = jsonDictionary {
        for key: String in json.keys{
            if object.respondsToSelector(Selector(key)) {
                print(key)
                object.setValue(json[key], forKey: key)
            }
        }
    }
    return object
}

let clazz1: NSObject.Type = SomeBaseClass.self
let base = fromJsonDictionary(["name":"fred"], clazz: SomeBaseClass.self)!
//base.printName()
print("hi \(base.name)")
base.respondsToSelector("name")
