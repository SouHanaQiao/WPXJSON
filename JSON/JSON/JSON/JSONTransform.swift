//
//  JSONTransform.swift
//  WPXJSON
//
//  Created by 葬花桥 on 2018/7/25.
//  Copyright © 2018年 葬花桥. All rights reserved.
//

import Foundation

public protocol JSONTransformable {
    
}

public protocol _BuiltInType: JSONTransformable {
    static func json_transformToBuiltIn(from json: JSON) -> Self?
    var json: JSON { get }
}

extension JSONTransformable {
    
    static func transform(from json: JSON) -> Self? {
        switch self {
        case let type as _BuiltInType.Type:
            return type.json_transformToBuiltIn(from: json) as? Self
        case let type as WPXCustomModelType.Type:
            return type.json_transformToModel(from: json) as? Self
        default:
            return nil
        }
    }
    
    var transformJSON: JSON {
        switch self {
        case let rawValue as _BuiltInType:
            return rawValue.json
        case let rawValue as WPXCustomModelType:
            return rawValue.json
        default:
            return .null
        }
    }
}

protocol _BuiltInIntegerPropertyProtocol: FixedWidthInteger, _BuiltInType {

}

extension _BuiltInIntegerPropertyProtocol {
    
    public static func json_transformToBuiltIn(from json: JSON) -> Self? {
        switch json {
        case .string(let s):
            return Self(s, radix: 10)
        case .number(let n):
            return n.value as? Self
        case .null:
            return Self()
        default:
            return nil
        }
    }
    
    public var json: JSON {
        return JSON(self)
    }
}
// MARK: - Int
extension Int: _BuiltInIntegerPropertyProtocol {}
extension UInt: _BuiltInIntegerPropertyProtocol {}
extension Int8: _BuiltInIntegerPropertyProtocol {}
extension Int16: _BuiltInIntegerPropertyProtocol {}
extension Int32: _BuiltInIntegerPropertyProtocol {}
extension Int64: _BuiltInIntegerPropertyProtocol {}
extension UInt8: _BuiltInIntegerPropertyProtocol {}
extension UInt16: _BuiltInIntegerPropertyProtocol {}
extension UInt32: _BuiltInIntegerPropertyProtocol {}
extension UInt64: _BuiltInIntegerPropertyProtocol {}

// MARK: - Bool
extension Bool: _BuiltInType {
    
    public static func json_transformToBuiltIn(from json: JSON) -> Bool? {
        switch json {
        case .string(let s):
            return Bool(s)
        case .bool(let b):
            return b
        case .number(let n):
            switch n {
            case .int(let i):
                return i > 0
            case .float(let f):
                return f > 0
            case .double(let d):
                return d > 0
            }
        case .null:
            return false
        default:
            return nil
        }
    }
    
    public var json: JSON {
        return JSON(self)
    }
}

// MARK: - Float
protocol _BuiltInFloatProtocol: _BuiltInType, LosslessStringConvertible {
    init()
    init(_ number: NSNumber)
}

extension _BuiltInFloatProtocol {
    public static func json_transformToBuiltIn(from json: JSON) -> Self? {
        switch json {
        case .string(let s):
            return Self(s)
        case .number(let n):
            return n.value as? Self
        case .bool(let b):
            return Self(NSNumber(value: b))
        case .null:
            return Self()
        default:
            return nil
        }
    }
    
    public var json: JSON {
        return JSON(self)
    }
}

extension Float: _BuiltInFloatProtocol {}
extension Double: _BuiltInFloatProtocol {}

// MARK: - String
extension String: _BuiltInType {
    public static func json_transformToBuiltIn(from json: JSON) -> String? {
        switch json {
        case .string(let s):
            return s
        case .bool(let b):
            return String(b)
        case .number(let n):
            return n.string
        case .array(let array):
            return array.jsonString
        case .object(let object):
            return object.jsonString
        case .null:
            return nil
        }
    }
    
    public var json: JSON {
        return JSON(self)
    }
}

// MARK: Collection Support : Array & Set
extension Collection {
    static func json_collectionTransformToBuiltIn(from json: JSON) -> [Iterator.Element]? {
        guard case let .array(arr) = json else {
            return nil
        }
        
        typealias Element = Iterator.Element
        var result: [Element] = [Element]()
        arr.forEach { (each) in
            if let element = (Element.self as? JSONTransformable.Type)?.transform(from: each) as? Element {
                result.append(element)
            } else if let element = each as? Element {
                result.append(element)
            }
        }
        return result
    }
    
    var collectionJSON: JSON {
        typealias Element = Iterator.Element
        var result: [JSON] = [JSON]()
        self.forEach { (each) in
            if let transformable = each as? JSONTransformable {
                let transValue = transformable.transformJSON
                result.append(transValue)
            } else {
                //                InternalLogger.logError("value: \(each) isn't transformable type!")
            }
        }
        return .array(result)
    }
}

extension Array: _BuiltInType {
    
    public static func json_transformToBuiltIn(from json: JSON) -> [Element]? {
        return self.json_collectionTransformToBuiltIn(from: json)
    }
    
    public var json: JSON {
        return collectionJSON
    }
}

extension Set: _BuiltInType {
    
    public static func json_transformToBuiltIn(from json: JSON) -> Set<Element>? {
        if let arr = self.json_collectionTransformToBuiltIn(from: json) {
            return Set(arr)
        }
        return nil
    }
    
    public var json: JSON {
        return collectionJSON
    }
}

// MARK: - Optional Support

extension Optional: _BuiltInType {
    
    public static func json_transformToBuiltIn(from json: JSON) -> Optional? {
        
        let jsonValue = json.value
        if let value = (Wrapped.self as? JSONTransformable.Type) {
            if let wrapped = value.transform(from: json) as? Wrapped {
                return Optional(wrapped)
            } else {
                return nil
            }
        } else if let value = jsonValue as? Wrapped {
            return Optional(value)
        }
                
        return nil
    }
    
    public var json: JSON {
        let wrapped: Any? = self.map {
            $0
        }
        if let value = wrapped {
            if let transformable = value as? JSONTransformable {
                return transformable.transformJSON
            } else {
                return JSON(self)
            }
        }
        
        return .null
    }
}

extension RawRepresentable where Self: _BuiltInType {
    
    public static func json_transformToBuiltIn(from json: JSON) -> Self? {
        if let transformableType = RawValue.self as? JSONTransformable.Type {
            if let typedValue = transformableType.transform(from: json) {
                let raw = Self(rawValue: typedValue as! RawValue)
                return raw
            }
        }
        return nil
    }
    
    public var json: JSON {
        return JSON(self.rawValue)
    }
}

public protocol WPXCustomModelType: JSONTransformable {
    init(dictionary: [String : Any])
}
extension WPXCustomModelType {
    static func json_transformToModel(from json: JSON) -> Self? {
        return self.init(dictionary: json.dictionary)
    }
    
    var json: JSON {
        if let type = self as? (_WPXJSONEncodable & Encodable) {
            return JSON(type.dictionary)
        }
        return .null
    }
}

extension Dictionary: _BuiltInType {
    public static func json_transformToBuiltIn(from json: JSON) -> [Key: Value]? {
        
        guard case .object(let dict) = json else {
            return nil
        }
        
        var result = [Key: Value]()
        
        for (key, value) in dict {
            if let sKey = key as? Key {
                if let nValue = (Value.self as? JSONTransformable.Type)?.transform(from: value) as? Value {
                    result[sKey] = nValue
                } else if let nValue = value as? Value {
                    result[sKey] = nValue
                }
            }
        }
        
        return result
    }
    
    public var json: JSON {
        
        var result = [String: Any]()
        for (key, value) in self {
            if let key = key as? String {
                if let transformable = value as? JSONTransformable {
                    result[key] = transformable.transformJSON
                } else if let value = value as? JSON {
                    result[key] = value
                }
            }
        }
        
        return JSON(result)
    }
}

extension JSON: _BuiltInType {
    public static func json_transformToBuiltIn(from json: JSON) -> JSON? {
        return json
    }
    
    public var json: JSON {
        return self
    }
}

extension WPXJSONAny: _BuiltInType {
    public static func json_transformToBuiltIn(from json: JSON) -> WPXJSONAny? {
        
        switch json {
        case .bool(let b):
            return WPXJSONAny(value: b)
        case .number(let n):
            return WPXJSONAny(value: n)
        case .string(let s):
            return WPXJSONAny(value: s)
        case .object(_):
            return WPXJSONAny(value: json.dictionary)
        case .array(_):
            return WPXJSONAny(value: json.array)
        case .null:
            return nil
        }
    }
    
    public var json: JSON {
        return JSON(value)
    }
}
