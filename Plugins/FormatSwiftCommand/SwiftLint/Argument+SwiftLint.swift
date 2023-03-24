extension Argument {
  static func swiftLintConfig(_ value: String) -> Argument {
    Argument(name: "swift-lint-config", value: value)
  }

  static func swiftLintCachePath(_ value: String) -> Argument {
    Argument(name: "swift-lint-cache-path", value: value)
  }

  static func swiftLintExecutablePath(_ value: String) -> Argument {
    Argument(name: "swift-lint-path", value: value)
  }

  static var swiftLintLintOnly: Argument {
    Argument(name: "swift-lint-lint-only", value: nil)
  }
}
