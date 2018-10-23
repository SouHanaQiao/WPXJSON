import Foundation

extension JSON: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let object = try? container.decode([String: JSON].self) {
            self = .object(object)
        } else if let array = try? container.decode([JSON].self) {
            self = .array(array)
        } else if let string = try? container.decode(String.self) {
            if string != "null" {
                self = .string(string)
            } else {
                self = .null
            }
            
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? container.decode(Int.self) {
            self = .number(.int(number))
        } else if let number = try? container.decode(Float.self) {
            self = .number(.float(number))
        } else if let number = try? container.decode(Double.self) {
            self = .number(.double(number))
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value.")
            )
        }
    }
}

struct JSONCodingKeys: CodingKey {
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}


extension KeyedDecodingContainer {
    
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            } else if try decodeNil(forKey: key) {
                dictionary[key.stringValue] = true
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}


extension JSON {
    
    var string: String {
        var jsonString = ""
    
        switch (self) {
        case .string(let s1):
            jsonString = s1
        case .number(let n):
            jsonString = String(n.string)
        case .object(_):
            jsonString = String(data: data, encoding: .utf8) ?? ""
        case .array(_):
            jsonString = String(data: data, encoding: .utf8) ?? ""
        case .bool(let b1):
            jsonString = String(b1)
        case .null:
            jsonString = "null"
        }
        return jsonString
    }
    
    var dictionary: [String : Any] {
        let json = self.value
        if json is [String : Any] {
            return json as! [String : Any]
        }
        return [:]
    }
    
    var array: [Any] {
        let json = self.value
        if json is [Any] {
            return json as! [Any]
        }
        return []
    }
    
    var data: Data {
        
        switch self {
        case .number(let number):
            return number.string.data(using: .utf8)!
        case .bool(let b):
            return String(b).data(using: .utf8)!
        case .null:
            return "null".data(using: .utf8)!
        case .string(let s):
            return s.data(using: .utf8)!
        case .object(_), .array(_):
            do {
                return try JSONEncoder().encode(self)
            } catch {
                return Data()
            }
        }
    }
}

extension JSON {
    func toModel<T>() throws -> T where T : _WPXJSONDecodable {
        let swiftObject = T.init()
        let mirror = Mirror(reflecting: swiftObject)
        var translateJson: JSON = self
        
        for case let(key?, value) in mirror.children {
            let v = self[key]
            let mi = Mirror(reflecting: value)
            
            if let modelPropertyType = mi.subjectType as? JSONTransformable.Type {
                
                
                if let transformValue = modelPropertyType.transform(from: v) {
                    translateJson[key] = transformValue.transformJSON
                } else if mi.subjectType is String.Type {
                    translateJson[key] = JSON(nil)
                }
            }
        }
        
        let translateJSONString = translateJson.string
        let data = translateJSONString.data(using: .utf8)!
        
        let model = try JSONDecoder().decode(T.self, from: data)
        return model
    }
    
    func toModels<T>() throws -> [T] where T : _WPXJSONDecodable {
        
        var modelArray = [T]()
        switch self {
        case .string(let string):
            if let d = string.data(using: .utf8) {
                let jsonObject = try JSONSerialization.jsonObject(with: d, options: [.allowFragments])
                if let array = jsonObject as? [Any] {
                    let json = JSON(array)
                    return try json.toModels()
                }
            }
        case .array(let array):
            for obj in array {
                let model: T = try obj.toModel()
                modelArray.append(model)
            }
        default:
            break
        }
        
        return modelArray
    }
}

extension Dictionary where Key == String, Value == JSON {
    var jsonString: String? {
        do {
            let json = try JSON(encodable: self)
            return json.string
        } catch {
            return nil
        }
    }
}
