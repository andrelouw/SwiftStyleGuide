import Foundation
import PackagePlugin

extension ArgumentBuildable where Self == SwiftLintArgumentBuilder {
  static var swiftLint: Self { SwiftLintArgumentBuilder() }
}

struct SwiftLintArgumentBuilder: ArgumentBuildable {
  func arguments(
    using argumentExtractor: inout ArgumentExtractor,
    context: PluginContext
  ) throws -> [String] {
    let parsedArguments = ParsedArguments.parse(using: &argumentExtractor)

    var arguments = Arguments()

    arguments.add(executablePath(from: context))
    arguments.add(cachePath(from: context))
    arguments.addIfNotNil(configFile(from: parsedArguments, context: context))

    return arguments.asStringArray()
  }

  private func executablePath(from _: PluginContext) -> Argument {
    // TODO: Rather use binary here and use context to get it
    .swiftLintExecutablePath("/opt/homebrew/bin/swiftlint")
  }

  private func cachePath(from context: PluginContext) -> Argument {
    .swiftLintCachePath(context.pluginWorkDirectory.string + "/swiftlint.cache")
  }

  private func configFile(from parsedArguments: ParsedArguments, context: PluginContext) -> Argument? {
    if let configFile = parsedArguments.configFile {
      return .swiftLintConfig(configFile)
    }

    if let configFile = context.package.directory.firstFileInParentDirectories(named: "swiftlint.yml") {
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
