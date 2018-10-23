//
//  Array.swift
//  CheckKaoQin
//
//  Created by 葬花桥 on 2018/7/4.
//

import Foundation

public extension Array where Element == JSON {
    var jsonString: String? {
        do {
            let json = try JSON(encodable: self)
            return json.string
        } catch {
            return nil
        }
    }
}

public extension Array where Element: WPXJSONCodable {
//    init(json: String) throws {
//        let j: JSON = JSON(json)
//        let models: [Element] = try j.toModels()
//        self = models
//    }
    
    init(json: String) {
        
        do {
            let j: JSON = JSON(json)
            let models: [Element] = try j.toModels()
            self = models
        } catch {
            self = [Element]()
        }
    }
    
//    init(json: [Any]) throws {
//        let j: JSON = JSON(json)
//        let models: [Element] = try j.toModels()
//        self = models
//    }
    init(json: [Any]) {
        do {
            let j: JSON = JSON(json)
            let models: [Element] = try j.toModels()
            self = models
        } catch {
            self = [Element]()
        }
    }
    
//    init(json: JSON) throws {
//        let models: [Element] = try json.toModels()
//        self = models
//    }
    init(json: JSON) {
        do {
            let models: [Element] = try json.toModels()
            self = models
        } catch {
            self = [Element]()
        }
    }
    
    var jsonString: String? {
        do {
            let json = try JSON(encodable: self)
            return json.string
        } catch {
            return nil
        }
    }
}
