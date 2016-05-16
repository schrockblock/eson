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
                    expect(json["has_taken_red_pill"] as? Bool).to(equal(neo.hasTakenRedPill))
                    expect(json["id"]).notTo(beNil())
                    expect(json["id"] as? Int).to(equal(neo.objectId))
                    
                    let ship: [String : AnyObject]? = json["ship"] as? [String : AnyObject]
                    expect(ship?["id"] as? Int).to(equal(neo.ship!.objectId))
                    expect(ship?["name"] as? String).to(equal(neo.ship!.name))
                }
            }
        }
    }
}
