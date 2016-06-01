//: Playground - noun: a place where people can play

import UIKit

//let neo = Human()
//neo.name = "Neo"
//neo.title = "The Chosen One"
//neo.shipName = "Nebuchadnezzar"

let number: Int = 3
let intString = "Human"

let intIns = NSClassFromString(intString)

public class ServerObject: NSObject {
    public var objectId: Int!
}

ServerObject().respondsToSelector(Selector("objectId"))

class NSStringSerializer: NSObject {
    var stringExample: String?
    
    func objectForValue(value: AnyObject?) -> AnyObject? {
        return value
    }
    func exampleValue() -> AnyObject {
        stringExample = String(NSDate().timeIntervalSince1970)
        return String()
    }
}

class Eph: NSObject {
    static var currentUser: Eph?
    var objectId = 0
    var name: String?
    var major: String?
    var extracurriculars: String?
    var currentActivity: String?
    var imageUrl: String?
    let deviceType = "ios"
    var pushToken: String?
    
    static func generateDummyUser() -> Eph {
        let user = Eph()
        user.name = "Ephraim Williams";
        user.major = "Defeating-the-French major";
        user.extracurriculars = "Being a Colonel, Establishing schools";
        user.currentActivity = "Namesake of the best college evar";
        user.imageUrl = "https://s-media-cache-ak0.pinimg.com/736x/9e/a7/90/9ea790fc99d386ff0126e1ee1ac8265a.jpg";
        return user
    }
    
}

let eph = Eph.generateDummyUser()
let serializer = NSStringSerializer()
serializer.exampleValue().dynamicType
eph.name!.dynamicType
eph.name!.dynamicType == serializer.exampleValue().dynamicType
serializer.exampleValue() is String

let y = serializer.exampleValue().dynamicType
let x = "".dynamicType
y == String.self
