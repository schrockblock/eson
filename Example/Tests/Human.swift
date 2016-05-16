//
//  Human.swift
//  Eson
//
//  Created by Elliot Schrock on 1/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class Human: ServerObject {
    public var name: String?
    public var title: String?
    public var age: Int?
    public var hasTakenRedPill = false
    public var ship: HumanShip?
    public var loveInterest: Human?
    
    public static func generateNeo() -> Human {
        let neo = Human()
        neo.objectId = 1
        neo.createdAt = NSDate(timeIntervalSinceNow: 53 * 365 * 24 * 60 * 60 * 1000)
        neo.name = "Neo"
        neo.title = "The One"
        neo.age = 25
        neo.hasTakenRedPill = true
        neo.ship = HumanShip.generateNebuchadnezzar()
        return neo
    }
    
    public static func generateTrinity() -> Human {
        let trinity = Human()
        trinity.objectId = 2
        trinity.createdAt = NSDate(timeIntervalSinceNow: 54 * 365 * 24 * 60 * 60 * 1000)
        trinity.name = "Trinity"
        trinity.title = "Badass"
        trinity.age = 24
        trinity.hasTakenRedPill = true
        return trinity
    }
}
