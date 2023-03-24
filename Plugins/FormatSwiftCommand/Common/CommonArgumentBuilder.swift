import PackagePlugin

extension ArgumentBuildable where Self == CommonArgumentBuilder {
  static var common: Self { CommonArgumentBuilder() }
}

struct CommonArgumentBuilder: ArgumentBuildable {
  func arguments(
    using argumentExtractor: inout ArgumentExtractor,
    context _: PluginContext
  ) throws -> [String] {
    let parsedArguments = ParsedArguments.parse(using: &argumentExtractor)
    var arguments = Arguments()

    arguments.addIfNotNil(log(from: parsedArguments))
    arguments.add(lintOnly(from: parsedArguments))

    return arguments.asStringArray()
  }

  private func log(from parsedArguments: ParsedArguments) -> Argument? {
    if parsedArguments.shouldLog {
      return .log
    }
    return nil
  }

  private func lintOnly(from parsedArguments: ParsedArguments) -> [Argument] {
    if parsedArguments.shouldOnlyLint {
      return [.swiftFormatLintOnly, .swiftLintLintOnly]
    }
    return []
  }
}

private struct ParsedArguments: ArgumentParsable {
  let shouldOnlyLint: Bool
  let shouldLog: Bool

  static func parse(
    using argumentExtractor: inout ArgumentExtractor
  ) -> ParsedArguments {
    ParsedArguments(
      shouldOnlyLint: hasFlag("lint", using: &argumentExtractor),
      shouldLog: hasFlag("log", using: &argumentExtractor)
    )
  }
}
