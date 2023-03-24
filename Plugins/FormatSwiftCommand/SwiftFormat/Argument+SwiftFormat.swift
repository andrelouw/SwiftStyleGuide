import Foundation

extension Argument {
  static func swiftFormatConfig(_ value: String) -> Argument {
    Argument(name: "swift-format-config", value: value)
  }

  static func swiftFormatCachePath(_ value: String) -> Argument {
    Argument(name: "swift-format-cache-path", value: value)
  }

  static func swiftFormatExecutablePath(_ value: String) -> Argument {
    Argument(name: "swift-format-path", value: value)
  }

  static func swiftFormatSwiftVersion(_ value: String) -> Argument {
    Argument(name: "swift-version", value: value)
  }

  static var swiftFormatLintOnly: Argument {
    Argument(name: "swift-format-lint-only", value: nil)
  }
}
