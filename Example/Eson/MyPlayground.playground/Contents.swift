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
