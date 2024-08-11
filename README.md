## JSON 모델을 디코딩할 때 간편하게 해주는 매크로

```swift
// 전
struct Model: Codable {
  let userInformation: UserInfo
  let totalUsers: Int
  
  enum CodingKeys: String, CodingKey {
    case userInformation = "user_information"
    case totalUsers = "total_users"
  }
}

struct UserInfo: Codable {
  let isAdmin: Bool
  let postCount: Int
  let isBanned: Bool
  
  enum CodingKeys: String, CodingKey {
    case isAdmin = "is_admin"
    case postCount = "post_count"
    case isBanned = "is_banned"
  }
}

// 매크로 사용 후
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
```
