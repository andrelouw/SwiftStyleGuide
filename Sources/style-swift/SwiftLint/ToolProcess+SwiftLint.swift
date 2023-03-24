extension ToolProcess {
  static func swiftLint(
    directories: [String],
    options: SwiftLint.Options
  ) -> ToolProcess {
    SwiftLint(
      directories: directories,
      options: options
    ).asToolProcess()
  }
}
