import Foundation

extension JSON: Encodable {

    public func encode(to encoder: Encoder) throws {

        var container = encoder.singleValueContainer()
        
        switch self {
        case let .array(array):
            try container.encode(array)
        case let .object(object):
            try container.encode(object)
        case let .string(string):
            try container.encode(string)
        case let .number(number):
            switch number {
            case .int(let i):
                try container.encode(i)
            case .float(let f):
                try container.encode(f)
            case .double(let d):
                try container.encode(d)
            }
        case let .bool(bool):
            try container.encode(bool)
        case .null:
            try container.encode("null")
        }
    }
}

extension JSON {
    
}

