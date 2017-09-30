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
                let eson = Eson()
                
                let json = eson.toJsonDictionary(eson)
                
                neo = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)!
                expect(neo).toNot(beNil())
            }
            
            it("can deserialize strings") {
                let human = Human.generateNeo()
                let json = ["name": human.name!, "title": human.title!] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.name).toNot(beNil())
                    expect(neo.name).to(equal(json["name"] as? String))
                    expect(neo.title).toNot(beNil())
                    expect(neo.title).to(equal(json["title"] as? String))
                }
            }
            
            it("ignores NSNull") {
                let trinityJson = ["name":"Trinity","title":NSNull()] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(trinityJson as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let trinity = deserializedHuman {
                    expect(trinity.title).to(beNil())
                }
            }
            
            it("can deserialize required Objective C primitives") {
                let human = Human.generateNeo()
                let json = ["age": human.age] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.age).notTo(beNil()) // THIS WILL FAIL IF AGE IS OPTIONAL
                    expect(neo.age).to(equal(json["age"] as? Int))
                }
            }
            
            it("can deserialize optional Objective C primitives into NSNumbers") {
                let json = ["has_taken_red_pill": true] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.hasTakenRedPill).notTo(beNil())
                    if let hasTakenRedPill = neo.hasTakenRedPill {
                        expect(hasTakenRedPill.boolValue).to(equal(json["has_taken_red_pill"] as? Bool))
                    }
                }
            }
            
            it("can deserialize to different property names") {
                let human = Human.generateNeo()
                let json = ["id": human.objectId] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.objectId).notTo(beNil())
                    expect(neo.objectId).to(equal(json["id"] as? Int))
                }
            }
            
            it("can deserialize dictionary properties") {
                let human = Human.generateNeo()
                let json = ["other_info": human.otherInfo as Any] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.otherInfo).notTo(beNil())
                    if let otherInfo = neo.otherInfo {
                        expect(otherInfo["likesWearingBlack"]).notTo(beNil())
                        if let obvi: String = otherInfo["likesWearingBlack"] as? String {
                            expect(obvi).to(equal("obvi"))
                        }
                    }
                }
            }
            
            it("can deserialize using consumer provided deserializers") {
                let shipJson = ["id": 1001]
                let json = ["ship": shipJson] as [String : Any]
                
                let eson = Eson()
                eson.deserializers?.append(HumanShipDeserializer())
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.ship).notTo(beNil());
                    if let ship = neo.ship {
                        expect(ship.objectId).to(equal(shipJson["id"]! as Int))
                    }
                }
            }
            
            it("can deserialize nested objects") {
                let trinityJson = ["id":2,"name":"Trinity","title":NSNull()] as [String : Any]
                let json = ["love_interest": trinityJson] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.loveInterest).toNot(beNil())
                    if let trinity = neo.loveInterest {
                        expect(type(of: trinity) == Human.self).to(beTrue())
                        if type(of: trinity) == Human.self {
                            expect(trinity.name).to(equal("Trinity"))
                            expect(trinity.objectId).to(equal(trinityJson["id"] as? Int))
                        }
                    }
                }
            }
            
            it("can deserialize nested arrays of objects") {
                let trinityJson = ["id":2,"name":"Trinity","title":NSNull()] as [String : Any]
                let morpheusJson = ["id":3,"name":"Morpheus","title":NSNull()] as [String : Any]
                let json = ["friends": [morpheusJson, trinityJson]] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.friends).notTo(beNil())
                    if let friends = neo.friends {
                        expect(friends.count).to(equal(2))
                        if friends.count > 0 {
                            expect(type(of: friends[0]) == Human.self).to(beTrue())
                        }
                    }
                }
            }
            
            it("can deserialize nested arrays of dictionaries") {
                let json = ["action_history": [["pill":"red"],["became":"the one"],["defeated":"Agent Smith"]]] as [String : Any]
                
                let eson = Eson()
                
                let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                expect(deserializedHuman).toNot(beNil())
                if let neo = deserializedHuman {
                    expect(neo.actionHistory).notTo(beNil())
                    if let actions: Array = neo.actionHistory {
                        expect(actions.count).to(equal(3))
                        if actions.count > 0 {
                            let first = actions[0]
                            let boolVal: Bool = first is Dictionary<AnyHashable, Any>
                            expect(boolVal).to(beTrue())
                        }
                    }
                }
            }
            
            if #available(iOS 10.0, *) {
                it("can deserialize iso dates using library provided deserializer") {
                    let human = Human.generateNeo()
                    
                    let formatter: ISO8601DateFormatter = ISO8601DateFormatter()
                    let dateString = formatter.string(from: human.createdAt)
                    let date = formatter.date(from: dateString)
                    
                    let json = ["created_at": dateString] as [String : Any]
                    
                    let eson = Eson()
                    eson.deserializers?.append(ISODateDeserializer())
                    
                    let deserializedHuman = eson.fromJsonDictionary(json as [String : AnyObject]?, clazz: Human.self)
                    expect(deserializedHuman).toNot(beNil())
                    if let neo = deserializedHuman {
                        expect(neo.createdAt).notTo(beNil())
                        expect(neo.createdAt).to(equal(date))
                    }
                }
            }
            
            // Alas, Swift does not yet have robust reflection of its own. That's why
            // Eson requires you to have your objects subclass NSObject. In the case
            // of JSON API format, generics seem like the obvious way to handle 
            // things. Unfortunately, since generics can't be represented in objc,
            // Eson can't set the value. Swift 4.2 or 5.0 is rumored to have better
            // reflection features, so, fingers crossed.
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
