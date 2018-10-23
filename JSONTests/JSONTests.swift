//
//  JSONTests.swift
//  JSONTests
//
//  Created by 葬花桥 on 2018/10/23.
//  Copyright © 2018年 葬花桥. All rights reserved.
//

import XCTest
import JSON

class JSONTests: XCTestCase {

    func testInitJSON() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // null
        let nullJSON = JSON.null
        XCTAssertEqual(nullJSON.value as! String, "null")
        
        // dict to JSON
        let dictJSON = JSON(["name":"SouHanaQiao", "age":28])
        let dictJSON2: JSON = ["name":"SouHanaQiao", "age":28]
        XCTAssertEqual(dictJSON.name, "SouHanaQiao")
        XCTAssertEqual(dictJSON.age, 28)
        XCTAssertEqual(dictJSON2.name, "SouHanaQiao")
        XCTAssertEqual(dictJSON2.age, 28)
        
        // array to JSON
        let arrayJSON = JSON(["SouHanaQiao", 28])
        let arrayJSON2: JSON = ["SouHanaQiao", 28]
        XCTAssertEqual(arrayJSON[0], "SouHanaQiao")
        XCTAssertEqual(arrayJSON[1], 28)
        XCTAssertEqual(arrayJSON2[0], "SouHanaQiao")
        XCTAssertEqual(arrayJSON2[1], 28)
        
        // string to JSON
        let stringJSON = JSON("Hello JSON")
        let stringJSON2: JSON = "Hello JSON"
        XCTAssertEqual(stringJSON.value as! String, "Hello JSON")
        XCTAssertEqual(stringJSON2.value as! String, "Hello JSON")
        
        // number to JSON
        let intJSON: JSON = 28
        let floatJSON: JSON = 28.0
        let doubleJSON = JSON(Number.double(28.0))
        XCTAssertEqual(intJSON.value as! Int, 28)
        XCTAssertEqual(floatJSON.value as! Float, 28)
        XCTAssertEqual(doubleJSON.value as! Double, 28)
    }

    func testJSONTo() {
        let json: JSON = ["students":[["name":"Tom", "age":22], ["name":"Lily", "age":20], ["name":"Jon", "age":25]]]
        // to dict
        print(json.dictionary)
        
        // to Array
        print(json.students.array)
        
        // to String
        print(json.string)
    }
    
    func testCodable() {
        let json: JSON = ["students":[["name":"Tom", "age":22], ["name":"Lily", "age":20], ["name":"Jon", "age":25]]]
        let data = try! JSONEncoder().encode(json)
        let dict = try! JSONDecoder().decode([String: WPXJSONAny].self, from: data)
        let data2 = try! JSONEncoder().encode(dict)
        let json2 = try! JSONDecoder().decode(JSON.self, from: data)
        XCTAssertEqual(json == json2, true)
    }
}
