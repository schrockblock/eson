//
//  Human.swift
//  Eson
//
//  Created by Elliot Schrock on 1/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class Human: ServerObject {
    var name: String?
    var title: String?
    var age: Int?
    var hasTakenRedPill = false
    var ship: HumanShip?
    
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
}
