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
import Eson_Example

class DeserializationTest: QuickSpec {
    override func spec() {
        describe("Eson") {
            it("can deserialize a class from JSON") {
                var neo = Human.generateNeo()
                let shipJson = ["id":1001]
                let trinityJson = ["id":2,"name":"Trinity","title":NSNull()] as [String : Any]
                let json = ["id":neo.objectId,"name":neo.name!,"age":neo.age!,"title":neo.title!,"ship":shipJson,"love_interest":trinityJson] as [String : Any]
                
                let eson = Eson()
                eson.deserializers?.append(HumanShipDeserializer())
                
                neo = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)!
                expect(neo).toNot(beNil())
                expect(neo.name).toNot(beNil())
                expect(neo.name).to(equal(json["name"] as? String))
                expect(neo.title).toNot(beNil())
                expect(neo.title).to(equal(json["title"] as? String))
                expect(neo.objectId).toNot(beNil())
                expect(neo.objectId).to(equal(json["id"] as? Int))
                expect(neo.age).notTo(beNil()) // THIS WILL FAIL IF AGE IS OPTIONAL
                expect(neo.age).to(equal(json["age"] as? Int))
                expect(neo.ship).notTo(beNil());
                if let ship = neo.ship {
                    expect(ship.objectId).to(equal(shipJson["id"]! as Int))
                }
                expect(neo.loveInterest).toNot(beNil())
                if let trinity = neo.loveInterest {
                    expect(type(of: trinity) == Human.self).to(beTrue())
                    if type(of: trinity) == Human.self {
                        expect(trinity.name).to(equal("Trinity"))
                        expect(trinity.objectId).to(equal(trinityJson["id"] as? Int))
                        expect(trinity.title).to(beNil())
                    }
                }
            }
            
            it("can deserialize a class from JSON API format") {
                let neo = Human.generateNeo()
                let shipJson = ["id":1001]
                let trinityJson = ["id":2,"name":"Trinity"] as [String : Any]
                let json = ["id":1, "attributes":["name":neo.name!,"title":neo.title!,"id":neo.objectId,"ship":shipJson,"love_interest":trinityJson]] as [String : Any]
                
                let jsonApiObject = Eson().fromJsonDictionary(json as [String : AnyObject]?, clazz: JsonApiDataObject<Human>.self)!
                expect(jsonApiObject).notTo(beNil())
                expect(jsonApiObject.attributes).notTo(beNil())
                if let attributes = jsonApiObject.attributes {
                    expect(attributes.name).to(equal(neo.name))
                }
            }
        }
    }
}

open class HumanShipDeserializer: Deserializer {
    open func nameOfClass() -> String {
        return "HumanShip"
    }
    
    open func valueForObject(_ object: AnyObject) -> AnyObject? {
        let eson = Eson()
        let ship = eson.fromJsonDictionary(object as? [String : AnyObject], clazz: HumanShip.self)!
        return ship
    }
}
