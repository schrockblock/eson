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
            it("can deserialize a class with strings from JSON") {
                let json = ["name":"Neo","title":"The Chosen One","ship_name":"Nebuchadnezzar"]
                
                let eson = Eson()
                let neo = eson.fromJsonDictionary(json, clazz: Human.self)
                expect(neo).toNot(beNil())
                expect(neo?.name).toNot(beNil())
                expect(neo?.name).to(equal(json["name"]))
                expect(neo?.title).toNot(beNil())
                expect(neo?.title).to(equal(json["title"]))
                expect(neo?.shipName).toNot(beNil())
                expect(neo?.shipName).to(equal(json["ship_name"]))
            }
        }
    }
}
