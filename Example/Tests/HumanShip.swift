//
//  HumanShip.swift
//  Eson
//
//  Created by Elliot Schrock on 2/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class HumanShip: Craft {
    public var name = ""
    
    public static func generateNebuchadnezzar() -> HumanShip {
        let nebuchadnezzar = HumanShip()
        nebuchadnezzar.objectId = 1001
        nebuchadnezzar.createdAt = NSDate(timeIntervalSinceNow: 53 * 365 * 24 * 60 * 60 * 1000)
        nebuchadnezzar.mass = 15000
        nebuchadnezzar.designation = "Mark III No. 11"
        nebuchadnezzar.name = "Nebuchadnezzar"
        return nebuchadnezzar
    }
}
