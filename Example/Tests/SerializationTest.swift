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

class SerializationTest: QuickSpec {
    override func spec() {
        describe("Eson") {
            it("can serialize a class with strings and ints to JSON") {
                let neo = Human()
                neo.name = "Neo"
                neo.title = "The Chosen One"
                neo.shipName = "Nebuchadnezzar"
                neo.age = 25
                
                let eson = Eson()
                let optionalJson = eson.toJsonDictionary(neo)
                expect(optionalJson).toNot(beNil())
                if let json = optionalJson {
                    expect(json["name"]).notTo(beNil())
                    expect(json["name"] as? String).to(equal(neo.name))
                    expect(json["title"]).notTo(beNil())
                    expect(json["title"] as? String).to(equal(neo.title))
                    expect(json["ship_name"]).notTo(beNil())
                    expect(json["ship_name"] as? String).to(equal(neo.shipName))
                    expect(json["age"]).notTo(beNil())
                    expect(json["age"] as? Int).to(equal(neo.age))
                }
            }
        }
    }
}
