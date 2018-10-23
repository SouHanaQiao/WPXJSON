# WPXJSON
Swift JSON framework, depend on Swift Reflection.
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
