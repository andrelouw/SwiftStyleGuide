import PackagePlugin

extension ArgumentBuildable where Self == SwiftFormatArgumentBuilder {
  static var swiftFormat: Self { SwiftFormatArgumentBuilder() }
}

struct SwiftFormatArgumentBuilder: ArgumentBuildable {
  func arguments(
    using argumentExtractor: inout ArgumentExtractor,
    context: CommandContext
  ) -> [String] {
    let parsedArguments = ParsedArguments.parse(using: &argumentExtractor)

    var arguments = Arguments()

    arguments.add(executablePath(from: context))
    arguments.add(cachePath(from: context))
    arguments.addIfNotNil(configFile(from: parsedArguments, context: context))
    arguments.addIfNotNil(swiftVersion(from: parsedArguments, context: context))

    return arguments.asStringArray()
  }

  private func executablePath(from _: CommandContext) -> Argument {
    // TODO: Rather use binary here and use context to get it
    .swiftFormatExecutablePath("/opt/homebrew/bin/swiftformat")
  }

  private func cachePath(from context: CommandContext) -> Argument {
    .swiftFormatCachePath(context.pluginWorkDirectory.string + "/swiftformat.cache")
  }

  private func configFile(from parsedArguments: ParsedArguments, context: CommandContext) -> Argument? {
    if let configFile = parsedArguments.configFile {
      return .swiftFormatConfig(configFile)
    }

    if let swiftFormatConfigPath = context.workingDirectory.firstFileInParentDirectories(named: "swiftformat") {
      return .swiftFormatConfig(swiftFormatConfigPath.string)
    }

    return nil
  }

  private func swiftVersion(from parsedArguments: ParsedArguments, context: CommandContext) -> Argument? {
    // When running on a SPM package we infer the minimum Swift version from the
    // `swift-tools-version` in `Package.swift` by default if the user doesn't
    // specify one manually
    let version = parsedArguments.swiftVersion ?? context.swiftVersion

    guard let version else {
      return nil
    }

    return .swiftFormatSwiftVersion(version)
  }
}

private struct ParsedArguments: ArgumentParsable {
  let configFile: String?
  let swiftVersion: String?

  static func parse(
    using argumentExtractor: inout ArgumentExtractor
  ) -> ParsedArguments {
    ParsedArguments(
      configFile: argument("swift-format-config", using: &argumentExtractor),
      swiftVersion: argument("swift-version", using: &argumentExtractor)
    )
  }
}
