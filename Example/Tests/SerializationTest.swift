//
//  SerializationTest.swift
//  Eson
//
//  Created by Elliot Schrock on 1/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import Eson
import Eson_Example

class SerializationTest: QuickSpec {
    override func spec() {
        describe("Eson") {
            it("can serialize a class to JSON") {
                let neo = Human.generateNeo()
                
                let eson = Eson()
                let optionalJson = eson.toJsonDictionary(neo)
                expect(optionalJson).toNot(beNil())
                if let json = optionalJson {
                    print(json)
                    expect(json["name"]).notTo(beNil())
                    expect(json["name"] as? String).to(equal(neo.name))
                    expect(json["title"]).notTo(beNil())
                    expect(json["title"] as? String).to(equal(neo.title))
                    expect(json["age"]).notTo(beNil())
                    expect(json["age"] as? Int).to(equal(neo.age))
                    expect(json["has_taken_red_pill"]).notTo(beNil())
                    if let hasTakenRedPill = json["has_taken_red_pill"] as? NSNumber {
                        expect(hasTakenRedPill.boolValue).to(equal(neo.hasTakenRedPill?.boolValue))
                    }
                    expect(json["id"]).notTo(beNil())
                    expect(json["id"] as? Int).to(equal(neo.objectId))
                    
                    let ship: [String : AnyObject]? = json["ship"] as? [String : AnyObject]
                    expect(ship?["id"] as? Int).to(equal(neo.ship!.objectId))
                    expect(ship?["name"] as? String).to(equal(neo.ship!.name))
                }
            }
            
            it("can serialize generic class") {
                let neo = Human.generateNeo()
                let jsonApiObject = JsonApiDataObject<Human>.generateDataObject(neo)
                
                let optionalJson = Eson().toJsonDictionary(jsonApiObject)
                expect(optionalJson).toNot(beNil())
                if let json = optionalJson {
                    expect(json["attributes"]).notTo(beNil())
                    expect(json["attributes"]?["name"]).notTo(beNil())
                    expect(String(describing: (json["attributes"]?["name"])!)).to(equal(neo.name!))
                }
            }
        }
    }
}
