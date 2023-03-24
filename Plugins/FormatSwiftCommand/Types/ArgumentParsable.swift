import PackagePlugin

protocol ArgumentParsable {
  static func parse(using argumentExtractor: inout ArgumentExtractor) -> Self
  static func argument(_ name: String, using argumentExtractor: inout ArgumentExtractor) -> String?
  static func hasFlag(_ name: String, using argumentExtractor: inout ArgumentExtractor) -> Bool
}

extension ArgumentParsable {
  static func argument(_ name: String, using argumentExtractor: inout ArgumentExtractor) -> String? {
    argumentExtractor.extractOption(named: name).last
  }

  static func hasFlag(_ name: String, using argumentExtractor: inout ArgumentExtractor) -> Bool {
    argumentExtractor.extractFlag(named: name) > 0
  }
}
