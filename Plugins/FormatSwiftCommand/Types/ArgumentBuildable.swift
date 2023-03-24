import PackagePlugin

protocol ArgumentBuildable {
  func arguments(using argumentExtractor: inout ArgumentExtractor, context: PluginContext) -> [String]
}
