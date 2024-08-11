import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - DTOMacro

public struct DTOMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let structDecl = declaration as? StructDeclSyntax
    else {
      return []
    }

    let properties = structDecl.memberBlock.members.compactMap { member -> (name: String, key: String)? in
      guard let variable = member.decl.as(VariableDeclSyntax.self),
            let pattern = variable.bindings.first?.pattern.as(IdentifierPatternSyntax.self)
      else {
        return nil
      }

      let name = pattern.identifier.text
      let key = variable.attributes.compactMap { attr -> String? in
        guard let attr = attr.as(AttributeSyntax.self),
              attr.attributeName.description == "Property",
              let arguments = attr.arguments?.as(LabeledExprListSyntax.self),
              let keyArg = arguments.first(where: { $0.label?.text == "key" }),
              let stringLiteral = keyArg.expression.as(StringLiteralExprSyntax.self) else {
          return nil
        }
        return stringLiteral.segments.description
      }.first ?? name

      return (name: name, key: key)
    }

    let codingKeySyntax = try EnumDeclSyntax("enum CodingKeys: String, CodingKey") {
      for property in properties {
        if property.name == property.key {
          try EnumCaseDeclSyntax("case \(raw: property.name)")
        } else {
          try EnumCaseDeclSyntax("case \(raw: property.name) = \(literal: property.key)")
        }
      }
    }

    return [DeclSyntax(codingKeySyntax)]
  }
}

extension DTOMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    return try [.init("extension \(raw: type.trimmedDescription): Codable {}")]
  }
}

// MARK: - PropertyMacro

public struct PropertyMacro: AccessorMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AccessorDeclSyntax] {
    guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
      return []
    }

    // Check if there's more than one @Property attribute
    let propertyAttributes = varDecl.attributes.filter {
      $0.as(AttributeSyntax.self)?.attributeName.description == "Property"
    }

    if propertyAttributes.count > 1 {
      context.diagnose(
        .init(
          node: Syntax(node),
          message: MacroExpansionDiagnostic.multiplePropertyApplication
        )
      )
    }

    return []
  }
}

enum MacroExpansionDiagnostic: String, DiagnosticMessage {
  case multiplePropertyApplication

  var severity: DiagnosticSeverity {
    switch self {
    case .multiplePropertyApplication:
      return .error
    }
  }

  var message: String {
    switch self {
    case .multiplePropertyApplication:
      return "@Property can only be applied once per property"
    }
  }

  var diagnosticID: MessageID {
    switch self {
    case .multiplePropertyApplication:
      return MessageID(domain: "DomainMacro", id: rawValue)
    }
  }
}

@main
struct DomainPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    DTOMacro.self,
    PropertyMacro.self,
  ]
}
