import Foundation
import PackagePlugin

@main
struct FormatSwiftCommand: CommandPlugin {
  func performCommand(context: PluginContext, arguments externalArguments: [String]) async throws {
    let styleSwift = try context.tool(named: "style-swift")
    let argumentBuilders: [ArgumentBuildable] = [.paths, .swiftFormat, .swiftLint, .common]
    var argumentExtractor = ArgumentExtractor(externalArguments)

    do {
      var arguments = try argumentBuilders.flatMap { try $0.arguments(using: &argumentExtractor, context: context) }
      arguments.append(contentsOf: argumentExtractor.remainingArguments)
      try styleSwift.run(arguments: arguments)
    } catch let error as PluginContext.Tool.RunError {
      Diagnostics.error(error.description)
    }
  }
}
