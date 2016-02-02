# Eson

[![CI Status](http://img.shields.io/travis/schrockblock/eson.svg?style=flat&branch=master)](https://travis-ci.org/schrockblock/eson)
[![Version](https://img.shields.io/cocoapods/v/Eson.svg?style=flat)](http://cocoapods.org/pods/Eson)
[![License](https://img.shields.io/cocoapods/l/Eson.svg?style=flat)](http://cocoapods.org/pods/Eson)
[![Platform](https://img.shields.io/cocoapods/p/Eson.svg?style=flat)](http://cocoapods.org/pods/Eson)

Eson is one of the simplest ways to get JSON serialization and deserialization in Swift.

## What makes Eson special?

- Eson allows you to serialize any type of class into a JSON dictionary, and deserialize JSON into any `NSObject`.

- It automatically converts between `llamaCase` property names and `snake_case_json_keys` for you

- You can easily set different JSON keys for your class properties by implementing the `EsonKeyMapper` protocol. For instance, if the json object contains a key `id` you can easily put that value into a property called `objectId`, and vice versa.

- You can register your own serializers and deserializers for your custom classes

## Usage

To run the tests, clone the repo, and run `pod install` from the Example directory first.

### Serialization

To serialize an object into a JSON dictionary, simply construct an instance of `Eson` and call `toJsonDictionary` on it:

```swift
let neo = Human.generateNeo()

let eson = Eson()
let optionalJson = eson.toJsonDictionary(neo)
```

Take a look at `SerializationTest.swift` for a more detailed example.

### Deserialization

To deserialize an object from a JSON dictionary, construct an instance of `Eson` and call `fromJsonDictionary` on it:

```swift
let json = ["name":"Neo","title":"The One","id":1]
let eson = Eson()
let neo = eson.fromJsonDictionary(json as? [String : AnyObject], clazz: Human.self)!
```

To register a custom deserializer, construct an `Eson` instance, and append a custom deserializer to its `deserializers`:

```swift
let shipJson = ["id":1001,"name":"Nebuchadnezzar"]
let json = ["name":"Neo","title":"The One","id":1,"ship":shipJson]

let eson = Eson()
eson.deserializers?.append(HumanShipDeserializer())
let neo = eson.fromJsonDictionary(json as? [String : AnyObject], clazz: Human.self)!
```

where `HumanShipDeserializer` implements two functions, `nameOfClass` and `valueForObject`:

```swift
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
```

### JSON keys vs. Property names

To convert between the JSON name for an object and the property name, all you have to do is implement a protocol (no subclassing!) called `EsonKeyMapper`, which has a method called `esonPropertyNameToKeyMap`. For instance: 

```swift
public class ServerObject: NSObject, EsonKeyMapper {
    var objectId: Int?
    
    public static func esonPropertyNameToKeyMap() -> [String : String] {
        return ["objectId":"id"]
    }
}
```

## Installation

Eson is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Eson", :git => 'https://github.com/schrockblock/eson'
```

## Author

Elliot Schrock

## License

Eson is available under the MIT license. See the LICENSE file for more info.
