//
//  HumanShip.swift
//  Eson
//
//  Created by Elliot Schrock on 2/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

open class HumanShip: Craft {
    open var name = ""
    
    open static func generateNebuchadnezzar() -> HumanShip {
        let nebuchadnezzar = HumanShip()
        nebuchadnezzar.objectId = 1001
        nebuchadnezzar.createdAt = Date(timeIntervalSinceNow: 53 * 365 * 24 * 60 * 60 * 1000)
        nebuchadnezzar.mass = 15000
        nebuchadnezzar.designation = "Mark III No. 11"
        nebuchadnezzar.name = "Nebuchadnezzar"
        return nebuchadnezzar
    }
}
