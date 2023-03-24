import PackagePlugin

protocol ArgumentBuildable {
  func arguments(
    using argumentExtractor: inout ArgumentExtractor,
    context: CommandContext
  ) throws -> [String]
}
