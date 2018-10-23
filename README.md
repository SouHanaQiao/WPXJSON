# WPXJSON
Swift JSON framework, depend on Swift Reflection.
由于Swift 原生Codable的诸多限制， 如：不支持Any类型，数据类型的严格对应，开发了这个用于更方便地解析json，更方便地转换json到struct或者class。
实现，使用联合枚举JSON抽象出json的 string, number, bool, map, array, null等基本类型，内部处理源类型与目标类型的转换，并添加各种工具方法
```
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

// string to Student

let jsonString = "{\"name\":\"souhanaqiao\", \"age\":28.0,\"sex\":1}"
let student2 = Student(jsonString: jsonString)

// array to Student
let array = [["name":"souhanaqiao", "age":28, "sex":1]]
let students = [Student](json: array)
```
