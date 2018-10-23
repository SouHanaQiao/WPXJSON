import Foundation

public enum Number: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    case int(Int)
    case float(Float)
    case double(Double)
    
    public var value: Any {
        switch self {
        case .int(let i):
            return i
        case .float(let f):
            return f
        case .double(let d):
            return d
        }
    }
    
    public var string: String {
        switch self {
        case .int(let i):
            return String(i)
        case .float(let f):
            return String(f)
        case .double(let d):
            return String(d)
        }
    }
    
    public var description: String {
        switch self {
        case .int(let i):
            return i.description
        case .float(let f):
            return f.description
        case .double(let d):
            return d.description
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .int(let i):
            return i.debugDescription
        case .float(let f):
            return f.debugDescription
        case .double(let d):
            return d.debugDescription
        }
    }
    
    public static func == (lhs: Number, rhs: Number) -> Bool {
        var lv: Double = 0
        switch lhs {
        case .int(let i):
            lv = Double(i)
        case .float(let f):
            lv = Double(f)
        case .double(let d):
            lv = Double(d)
        }
        
        var rv: Double = 0
        switch rhs {
        case .int(let i):
            rv = Double(i)
        case .float(let f):
            rv = Double(f)
        case .double(let d):
            rv = Double(d)
        }
        
        return lv == rv
    }
}

@dynamicMemberLookup
public enum JSON {
    case string(String)
    case number(Number)
    case object([String: JSON])
    case array([JSON])
    case bool(Bool)
    case null
}

extension JSON: Equatable {

    public static func == (lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.string(let s1), .string(let s2)):
            return s1 == s2
        case (.number(let n1), .number(let n2)):
            return n1 == n2
        case (.object(let o1), .object(let o2)):
            return o1 == o2
        case (.array(let a1), .array(let a2)):
            return a1 == a2
        case (.bool(let b1), .bool(let b2)):
            return b1 == b2
        case (.null, .null):
            return true
        default:
            return false
        }
    }
}

extension JSON {
    
    var value: Any {
        get {
            return self.hash()
        }
    }
    
    private func hash()  -> Any {
        var json: Any = "null"
        switch (self) {
        case .string(let s1):
            json = s1
        case .number(let n):
            json = n.value
        case .object(let o1):
            var map: [String: Any] = [:]
            for (key, value) in o1 {
                map[key] = value.hash()
            }
            json = map
        case .array(let a1):
            var array: [Any] = []
            for json in a1 {
                array.append(json.hash())
            }
            json = array
        case .bool(let b1):
            json = b1
        case .null:
            json = "null"
        }
        return json
    }
    
    subscript(key: String) -> JSON {
        get {
            var json: JSON
            json = .null
            switch self {
            case .object(let o):
                json = o[key] ?? .null
            default:
                json = .null
            }
            return json
        }
        set (newValue) {
            switch self {
            case .string: break
            case .number: break
            case .object(var o1):
                o1[key] = newValue
                self = .object(o1)
            case .array: break
            case .bool: break
            case .null: break
            }
        }
    }
    
    subscript(index: Int) -> JSON {
        get {
            var json: JSON
            json = .null
            switch self {
            case .array(let a1):
                return a1[index]
            default:
                json = .null
            }
            return json
        }
        set (newValue) {
            switch self {
            case .string: break
            case .number: break
            case .object: break
            case .array(var a1):
                a1[index] = newValue
                self = .array(a1)
            case .bool: break
            case .null: break
            }
        }
    }
    
    #if swift(>=4.2)
    /// swift 4.2 特性 可以像使用成员变量一样使用下标语法
    subscript(dynamicMember member: String) -> JSON {
        get {
            var json: JSON
            json = .null
            switch self {
            case .object(let o):
                json = o[member] ?? .null
            default:
                json = .null
            }
            return json
        }
        set {
            switch self {
            case .string: break
            case .number: break
            case .object(var o1):
                o1[member] = newValue
                self = .object(o1)
            case .array: break
            case .bool: break
            case .null: break
            }
        }
    }
    #endif
    
    mutating func append(json: JSON) {
        switch self {
        case .string: break
        case .number: break
        case .object: break
        case .array(var a1):
            a1.append(json)
            self = .array(a1)
        case .bool: break
        case .null: break
        }
    }
    
    func forEach(callBack: (String, Any)->Void) {
        switch self {
        case .string: break
        case .number: break
        case .object(let o1):
            for (key, value) in o1 {
                callBack(key, value.hash())
            }
        case .array: break
        case .bool: break
        case .null: break
        }
    }
    
    func forEach(callBack: (Any)->Void) {
        switch self {
        case .string: break
        case .number: break
        case .object: break
        case .array(let a1):
            for json in a1 {
                callBack(json.hash())
            }
        case .bool: break
        case .null: break
        }
    }
    
    mutating func remove(key: String) {
        switch self {
        case .string: break
        case .number: break
        case .object(var o1):
            o1.removeValue(forKey: key)
            self = .object(o1)
        case .array: break
        case .bool: break
        case .null: break
        }
    }
    
    mutating func remove(index: Int) {
        switch self {
        case .string: break
        case .number: break
        case .object: break
        case .array(var a1):
            a1.remove(at: index)
            self = .array(a1)
        case .bool: break
        case .null: break
        }
    }
}

extension Int : CustomDebugStringConvertible {
    
    /// A textual representation of the value, suitable for debugging.
    public var debugDescription: String { get {
            return String(self)
        }
    }
}

extension JSON: CustomStringConvertible {
    public var description: String {
        /*switch self {
        case .string(let str):
            return str.debugDescription
        case .number(let num):
            return num.debugDescription
        case .bool(let bool):
            return bool.description
        case .null:
            return "null"
        default:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            return try! String(data: encoder.encode(self), encoding: .utf8)!
        }*/
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? "null"
        } catch {
            return "null"
        }

    }
}

extension JSON: CustomDebugStringConvertible {

    public var debugDescription: String {
        /*switch self {
        case .string(let str):
            return str.debugDescription
        case .number(let num):
            return num.debugDescription
        case .bool(let bool):
            return bool.description
        case .null:
            return "null"
        default:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            return try! String(data: encoder.encode(self), encoding: .utf8)!
        }*/
        return description
    }
}
