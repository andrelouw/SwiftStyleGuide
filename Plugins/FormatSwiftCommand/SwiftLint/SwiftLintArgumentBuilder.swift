import Foundation
import PackagePlugin

extension ArgumentBuildable where Self == SwiftLintArgumentBuilder {
  static var swiftLint: Self { SwiftLintArgumentBuilder() }
}

struct SwiftLintArgumentBuilder: ArgumentBuildable {
  func arguments(
    using argumentExtractor: inout ArgumentExtractor,
    context: CommandContext
  ) throws -> [String] {
    let parsedArguments = ParsedArguments.parse(using: &argumentExtractor)

    var arguments = Arguments()

    try arguments.add(executablePath(from: context))
    arguments.add(cachePath(from: context))
    arguments.addIfNotNil(configFile(from: parsedArguments, context: context))

    return arguments.asStringArray()
  }

  private func executablePath(from context: CommandContext) throws -> Argument {
    let swiftLintPath = try context.tool(named: "swiftlint").path.string
    return .swiftLintExecutablePath(swiftLintPath)
  }

  private func cachePath(from context: CommandContext) -> Argument {
    .swiftLintCachePath(context.pluginWorkDirectory.string + "/swiftlint.cache")
  }

  private func configFile(from parsedArguments: ParsedArguments, context: CommandContext) -> Argument? {
    if let configFile = parsedArguments.configFile {
      return .swiftLintConfig(configFile)
    }

    if let configFile = context.workingDirectory.firstFileInParentDirectories(named: "swiftlint.yml") {
      return .swiftLintConfig(configFile.string)
    }

    return nil
  }
}

private struct ParsedArguments: ArgumentParsable {
  let configFile: String?

  static func parse(
    using argumentExtractor: inout ArgumentExtractor
  ) -> ParsedArguments {
    ParsedArguments(
      configFile: argument("swift-lint-config", using: &argumentExtractor)
    )
  }
}
