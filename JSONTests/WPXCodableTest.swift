//
//  WPXCodableTest.swift
//  JSONTests
//
//  Created by 葬花桥 on 2018/10/23.
//  Copyright © 2018年 葬花桥. All rights reserved.
//

import XCTest
import JSON

class WPXCodableTests: XCTestCase {
    
    func testStruct() {
        enum Sex: Int, WPXJSONEnumCodable {
            case male = 1
            case female = 0
        }
        
        struct Student: WPXJSONCodable {
            var name: String
            var age: Int
            var sex: Sex
        }
        // dict to Student
        let dict: [String : Any] = ["name":"souhanaqiao", "age":28, "sex":1]
        let student = Student(dictionary: dict)
        XCTAssertEqual(student.name, "souhanaqiao")
        XCTAssertEqual(student.age, 28)
        XCTAssertEqual(student.sex == Sex.male, true)
        // string to Student
        let jsonString = "{\"name\":\"souhanaqiao\", \"age\":28.0,\"sex\":1}"
        let student2 = Student(jsonString: jsonString)
        XCTAssertEqual(student2.name, "souhanaqiao")
        XCTAssertEqual(student2.age, 28)
        XCTAssertEqual(student2.sex, Sex.male)
        
        // array to Student
        let array = [["name":"souhanaqiao", "age":28, "sex":1]]
        let students = [Student](json: array)
        XCTAssertEqual(students[0].name, "souhanaqiao")
        XCTAssertEqual(students[0].age, 28)
        XCTAssertEqual(students[0].sex, Sex.male)
    }
    
    func testClass() {
        enum Sex: Int, WPXJSONEnumCodable {
            case male = 1
            case female = 0
        }
        
        class Student: WPXJSONCodable {
            var name: String
            var age: Int
            var sex: Sex
        }
        // dict to Student
        let dict: [String : Any] = ["name":"souhanaqiao", "age":28, "sex":1]
        let student = Student(dictionary: dict)
        XCTAssertEqual(student.name, "souhanaqiao")
        XCTAssertEqual(student.age, 28)
        XCTAssertEqual(student.sex == Sex.male, true)
        // string to Student
        let jsonString = "{\"name\":\"souhanaqiao\", \"age\":28.0,\"sex\":1}"
        let student2 = Student(jsonString: jsonString)
        XCTAssertEqual(student2.name, "souhanaqiao")
        XCTAssertEqual(student2.age, 28)
        XCTAssertEqual(student2.sex, Sex.male)
        
        // array to Student
        let array = [["name":"souhanaqiao", "age":28, "sex":1]]
        let students = [Student](json: array)
        XCTAssertEqual(students[0].name, "souhanaqiao")
        XCTAssertEqual(students[0].age, 28)
        XCTAssertEqual(students[0].sex, Sex.male)
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
