//
//  Human.swift
//  Eson
//
//  Created by Elliot Schrock on 1/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

open class Human: ServerObject {
    open var name: String?
    open var title: String?
    open var age: Int = 0
    open var hasTakenRedPill: NSNumber?
    open var ship: HumanShip?
    open var loveInterest: Human?
    open var friends: [Human]?
    open var otherInfo: Dictionary<AnyHashable, Any>?
    open var actionHistory: [Dictionary<AnyHashable, Any>]?
    
    open static func generateNeo() -> Human {
        let neo = Human()
        neo.objectId = 1
        neo.createdAt = Date(timeIntervalSinceNow: 53 * 365 * 24 * 60 * 60)
        neo.name = "Neo"
        neo.title = "The One"
        neo.age = 25
        neo.hasTakenRedPill = true
        neo.ship = HumanShip.generateNebuchadnezzar()
        neo.friends = [generateMorpheus(), generateTrinity()]
        neo.otherInfo = ["likesWearingBlack": "obvi"]
        neo.actionHistory = [["pill":"red"],["became":"the one"],["defeated":"Agent Smith"]]
        return neo
    }
    
    open static func generateTrinity() -> Human {
        let trinity = Human()
        trinity.objectId = 2
        trinity.createdAt = Date(timeIntervalSinceNow: 54 * 365 * 24 * 60 * 60 * 1000)
        trinity.name = "Trinity"
        trinity.age = 24
        trinity.hasTakenRedPill = true
        trinity.otherInfo = ["likesWearingBlack": "black leather plz"]
        return trinity
    }
    
    open static func generateMorpheus() -> Human {
        let morpheus = Human()
        morpheus.objectId = 3
        morpheus.createdAt = Date(timeIntervalSinceNow: 24 * 365 * 24 * 60 * 60 * 1000)
        morpheus.name = "Morpheus"
        morpheus.age = 45
        morpheus.hasTakenRedPill = true
        morpheus.otherInfo = ["likesWearingBlack": "only if it's ripped"]
        return morpheus
    }
}
