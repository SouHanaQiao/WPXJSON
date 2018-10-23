//
//  Codable.swift
//  CheckKaoQin
//
//  Created by 葬花桥 on 2018/7/4.
//

import Foundation


public protocol WPXJSONEnumCodable: _BuiltInType, DefaultConstructor, Codable {
}

public extension RawRepresentable where Self: WPXJSONEnumCodable {
    init() {
        let pointer = UnsafeMutablePointer<Self>.allocate(capacity: 1)
        self = pointer.move()
        
        #if swift(>=4.1)
        pointer.deallocate()
        #else
        pointer.deallocate(capacity: 1)
        #endif
    }
}

public protocol WPXJSONCodable: _WPXJSONEncodable, _WPXJSONLiteralDecodable, WPXCustomModelType {
    
}

public protocol _WPXJSONEncodable: CustomStringConvertible, CustomDebugStringConvertible {}

extension _WPXJSONEncodable where Self: Encodable {
    
    public var jsonString: String? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            return try String(data: encoder.encode(self), encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    public var dictionary: [String : Any]? {
        do {
            let json = try JSON(encodable: self)
            return json.dictionary
        } catch {
            return nil
        }
    }
    
    public var description: String {
        return jsonString ?? "null"
    }
    
    public var debugDescription: String {
        return jsonString ?? "null"
    }
}

public protocol _WPXJSONDecodable: Codable {
    init()
}

public extension _WPXJSONDecodable {
    
    public init() {
        self = try! createInstance(of: Self.self) as! Self
    }
    
    public init(jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            do {
                let json = try JSONDecoder().decode(JSON.self, from: data)
                self = try json.toModel()
                return
            } catch {
                self.init()
            }
        }
        self.init()
    }
    
    public init(dictionary: [String : Any]) {
        do {
            if dictionary.count > 0 {
                let json = JSON(dictionary)
                self = try json.toModel()
            } else {
                self.init()
            }
        } catch {
            self.init()
        }
    }
    
    public init(json: JSON) {
        do {
            self = try json.toModel()
        } catch {
            self.init()
        }
    }
}

public protocol _WPXJSONDecodeFromString: _WPXJSONDecodable, ExpressibleByStringLiteral {}
extension _WPXJSONDecodeFromString {
    public init(stringLiteral value: String) {
        self = Self(jsonString: value)
    }
}

public protocol _WPXJSONDecodeFormDictionary : _WPXJSONDecodable, ExpressibleByDictionaryLiteral {}
extension _WPXJSONDecodeFormDictionary {
    public init(dictionaryLiteral elements: (String, Any)...) {
        var object: [String : Any] = [:]
        for (k, v) in elements {
            object[k] = v
        }
        
        self.init(dictionary: object)
    }
    
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var object: [String : JSON] = [:]
        for (k, v) in elements {
            object[k] = v
        }
        let json: JSON = .object(object)
        self.init(dictionary: json.dictionary)
    }
}

public protocol _WPXJSONLiteralDecodable: _WPXJSONDecodeFromString, _WPXJSONDecodeFormDictionary {
    
}

// Wrap of Any
public final class WPXJSONAny: Codable {
    public let value: Any
    
    init(value: Any) {
        self.value = value
    }
    
    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(WPXJSONAny.self, context)
    }
    
    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }
    
    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return _WPXJSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return _WPXJSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: _WPXJSONAnyCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout KeyedDecodingContainer<_WPXJSONAnyCodingKey>, forKey key: _WPXJSONAnyCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return _WPXJSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: _WPXJSONAnyCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }
    
    static func decodeDictionary(from container: inout KeyedDecodingContainer<_WPXJSONAnyCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }
    
    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is _WPXJSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: _WPXJSONAnyCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout KeyedEncodingContainer<_WPXJSONAnyCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = _WPXJSONAnyCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is _WPXJSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: _WPXJSONAnyCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is _WPXJSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try WPXJSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: _WPXJSONAnyCodingKey.self) {
            self.value = try WPXJSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try WPXJSONAny.decode(from: container)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try WPXJSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: _WPXJSONAnyCodingKey.self)
            try WPXJSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try WPXJSONAny.encode(to: &container, value: self.value)
        }
    }
}

class _WPXJSONNull: Codable {
    public init() {
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(_WPXJSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class _WPXJSONAnyCodingKey : CodingKey {
    let key: String
    
    required init?(intValue: Int) {
        return nil
    }
    
    required init?(stringValue: String) {
        key = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    var stringValue: String {
        return key
    }
}
