//
//  DeserializationTest.swift
//  Eson
//
//  Created by Elliot Schrock on 1/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Eson

class DeserializationTest: QuickSpec {
    override func spec() {
        describe("Eson") {
            it("can deserialize a class from JSON") {
                var neo = Human.generateNeo()
                let shipJson = ["id":1001]
                let json = ["name":neo.name!,"title":neo.title!,"id":neo.objectId,"ship":shipJson]
                
                let eson = Eson()
                eson.deserializers?.append(HumanShipDeserializer())
                
                neo = eson.fromJsonDictionary(json as? [String : AnyObject], clazz: Human.self)!
                expect(neo).toNot(beNil())
                expect(neo.name).toNot(beNil())
                expect(neo.name).to(equal(json["name"] as? String))
                expect(neo.title).toNot(beNil())
                expect(neo.title).to(equal(json["title"] as? String))
                expect(neo.objectId).toNot(beNil())
                expect(neo.objectId).to(equal(json["id"] as? Int))
                expect(neo.ship!.objectId).to(equal(shipJson["id"]! as Int))
            }
        }
    }
}

public class HumanShipDeserializer: Deserializer {
    public func nameOfClass() -> String {
        return "HumanShip"
    }
    
    public func valueForObject(object: AnyObject) -> AnyObject? {
        let eson = Eson()
        let ship = eson.fromJsonDictionary(object as? [String : AnyObject], clazz: HumanShip.self)!
        return ship
    }
}
