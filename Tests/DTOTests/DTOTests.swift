import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(DTOMacros)
import DTOMacros

let testMacros: [String: Macro.Type] = [
  "DTO": DTOMacro.self,
]
#endif

final class DTOTests: XCTestCase {
  func testDTOMacroWithBasicType() throws {
    assertMacroExpansion(
      """
      @DTO
      struct TestModel {
        let name: String
        let age: Int
      }
      """,
      expandedSource:
      """
      struct TestModel {
        let name: String
        let age: Int

          enum CodingKeys: String, CodingKey {
              case name
              case age
          }
      }

      extension TestModel: Codable {
      }
      """,
      macros: testMacros
    )
  }

  func testDTOMacroIncludingEnumType() throws {
    assertMacroExpansion(
    """
    @DTO
    struct TestModel {
      let name: String
      let age: Int
      let gender: Gender
    }

    @DTO
    enum Gender: String {
      case male
      case female
    }
    """,
    expandedSource:
    """
    struct TestModel {
      let name: String
      let age: Int
      let gender: Gender

        enum CodingKeys: String, CodingKey {
            case name
            case age
            case gender
        }
    }
    enum Gender: String {
      case male
      case female
    }

    extension TestModel: Codable {
    }

    extension Gender: Codable {
    }
    """,
    macros: testMacros
    )
  }

  func testDTOMacroIncludingPropertyType() throws {
    assertMacroExpansion(
    """
    @DTO
    struct TestModel {
      let name: String
      let age: Int
      @Property(key: "created_at") let createTime: Date
    }
    """,
    expandedSource:
    """
    struct TestModel {
      let name: String
      let age: Int
      @Property(key: "created_at") let createTime: Date

        enum CodingKeys: String, CodingKey {
            case name
            case age
            case createTime = "created_at"
        }
    }

    extension TestModel: Codable {
    }
    """,
    macros: testMacros
    )
  }

  func testDTOMacroIncludingPropertyType2() throws {
    assertMacroExpansion(
    """
    @DTO
    struct TestModel {
      let name: String
      let age: Int
      @Property(key: "user_information") let userInfo: UserInfo
    }

    @DTO
    struct UserInfo {
      @Property(key: "is_admin") let isAdmin: Bool
      let follower: Int
    }
    """,
    expandedSource:
    """
    struct TestModel {
      let name: String
      let age: Int
      @Property(key: "user_information") let userInfo: UserInfo

        enum CodingKeys: String, CodingKey {
            case name
            case age
            case userInfo = "user_information"
        }
    }
    struct UserInfo {
      @Property(key: "is_admin") let isAdmin: Bool
      let follower: Int

        enum CodingKeys: String, CodingKey {
            case isAdmin = "is_admin"
            case follower
        }
    }

    extension TestModel: Codable {
    }

    extension UserInfo: Codable {
    }
    """,
    macros: testMacros
    )
  }
}
