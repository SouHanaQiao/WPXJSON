import Foundation

extension JSON {

    public init(_ value: Any?) {
        switch value {
        case let num as Float:
            self = .number(.float(num))
        case let num as Int:
            self = .number(.int(num))
        case let num as Double:
            self = .number(.double(num))
        case let num as Number:
            self = .number(num)
        case let str as String:
            self = .string(str)
        case let bool as Bool:
            self = .bool(bool)
        case let array as [Any]:
            self = .array( array.map(JSON.init))
        case let dict as [String : Any]:
            self = .object( dict.mapValues(JSON.init))
        case let json as JSON:
            self = json
        case let json as WPXJSONAny:
            self = JSON(json.value)
        default:
            self = .null
        }
    }
    
    public init(jsonString: String) {
        let data = jsonString.data(using: .utf8)
        if let data = data {
            do {
                self = try JSONDecoder().decode(JSON.self, from: data)
            } catch {
                self = .null
            }
        } else {
            self = .null
        }
    }
}

extension JSON {

    /// Create a JSON value from a `Codable`. This will give you access to the “raw”
    /// encoded JSON value the `Codable` is serialized into. And hopefully, you could
    /// encode the resulting JSON value and decode the original `Codable` back.
    public init<T: Codable>(codable: T) throws {
        let encoded = try JSONEncoder().encode(codable)
        self = try JSONDecoder().decode(JSON.self, from: encoded)
    }
    
    public init<T: Encodable>(encodable: T) throws {
        let encoded = try JSONEncoder().encode(encodable)
        self = try JSONDecoder().decode(JSON.self, from: encoded)
    }
}

extension JSON: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByNilLiteral {

    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSON: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Any...) {
        self = JSON(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Any)...) {
        var object: [String: Any] = [:]
        for (k, v) in elements {
            object[k] = v
        }
        self = JSON(object)
    }
}

extension JSON: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Float) {
        self = .number(.float(value))
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int) {
        self = .number(.int(value))
    }
}

extension JSON: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}
