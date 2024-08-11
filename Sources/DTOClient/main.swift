import DTO
import Foundation

@DTO
struct TestModel {
  @Property(key: "created_at") let createTime: Date
  let name: String
  let age: Int
  let gender: Gender
}

@DTO
enum Gender: String {
  case male = "멍"
  case female
}

@DTO
struct Model {
  @Property(key: "user_information") let userInfo: UserInfo
  @Property(key: "total_users") let totalUsers: Int
}

@DTO
struct UserInfo {
  @Property(key: "is_admin") let isAdmin: Bool
  @Property(key: "post_count") let postCount: Int
  @Property(key: "is_banned") let isBanned: Bool
}


let response = Model(userInfo: .init(isAdmin: false, postCount: 0, isBanned: true), totalUsers: 0)
let data = try! JSONEncoder().encode(response)

let jsonObject = try! JSONSerialization.jsonObject(with: data)
let jsonString = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
print(String(data: jsonString, encoding: .utf8)!)

let json = """
{
  "total_users" : 0,
  "user_information" : {
    "post_count" : 0,
    "is_banned" : true,
    "is_admin" : false
  }
}
""".data(using: .utf8)!

print(try? JSONDecoder().decode(Model.self, from: json))

