@attached(extension, conformances: Codable)
@attached(member, names: named(CodingKeys))
public macro DTO() = #externalMacro(module: "DTOMacros", type: "DTOMacro")

@attached(accessor, names: named(willSet))
public macro Property(key: String? = nil) = #externalMacro(module: "DTOMacros", type: "PropertyMacro")
