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
    open var age: Int?
    open var hasTakenRedPill = false
    open var ship: HumanShip?
    open var loveInterest: Human?
    open var friends: [Human]?
    
    open static func generateNeo() -> Human {
        let neo = Human()
        neo.objectId = 1
        neo.createdAt = Date(timeIntervalSinceNow: 53 * 365 * 24 * 60 * 60 * 1000)
        neo.name = "Neo"
        neo.title = "The One"
        neo.age = 25
        neo.hasTakenRedPill = true
        neo.ship = HumanShip.generateNebuchadnezzar()
        neo.friends = [generateMorpheus(), generateTrinity()]
        return neo
    }
    
    open static func generateTrinity() -> Human {
        let trinity = Human()
        trinity.objectId = 2
        trinity.createdAt = Date(timeIntervalSinceNow: 54 * 365 * 24 * 60 * 60 * 1000)
        trinity.name = "Trinity"
        trinity.age = 24
        trinity.hasTakenRedPill = true
        return trinity
    }
    
    open static func generateMorpheus() -> Human {
        let morpheus = Human()
        morpheus.objectId = 3
        morpheus.createdAt = Date(timeIntervalSinceNow: 24 * 365 * 24 * 60 * 60 * 1000)
        morpheus.name = "Morpheus"
        morpheus.age = 45
        morpheus.hasTakenRedPill = true
        return morpheus
    }
}
