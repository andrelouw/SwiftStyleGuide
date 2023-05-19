extension ToolProcess {
  static func swiftFormat(
    directories: [String],
    options: SwiftFormat.Options
  ) -> ToolProcess {
    SwiftFormat(
      directories: directories,
      options: options
    ).asToolProcess()
  }
}
