import Foundation
import PackagePlugin

@main
struct FormatSwiftCommand {
  private func performCommand(
    context: CommandContext,
    inputPaths: [String],
    argumentExtractor: inout ArgumentExtractor
  ) throws {
    let styleSwift = try context.tool(named: "style-swift")
    let argumentBuilders: [ArgumentBuildable] = [.swiftFormat, .swiftLint, .common]

    var arguments = try argumentBuilders.flatMap { try $0.arguments(using: &argumentExtractor, context: context) }
    arguments.append(contentsOf: argumentExtractor.remainingArguments)
    arguments.append(contentsOf: inputPaths)

    do {
      try styleSwift.run(arguments: arguments)
    } catch let error as PluginContext.Tool.RunError {
      Diagnostics.error(error.description)
    }
  }
}

extension FormatSwiftCommand: CommandPlugin {
  func performCommand(
    context: PluginContext,
    arguments: [String]
  ) async throws {
    var argumentExtractor = ArgumentExtractor(arguments)

    let inputPaths = try PathArgumentBuilder().arguments(using: &argumentExtractor, context: context)

    try performCommand(
      context: context,
      inputPaths: inputPaths,
      argumentExtractor: &argumentExtractor
    )
  }
}

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension FormatSwiftCommand: XcodeCommandPlugin {
    func performCommand(
      context: XcodePluginContext,
      arguments externalArgs: [String]
    ) throws {
      var argumentExtractor = ArgumentExtractor(externalArgs)

//    let inputPaths = try PathArgumentBuilder().arguments(using: &argumentExtractor, context: context)
      let inputPaths = [String]()

      try performCommand(
        context: context,
        inputPaths: inputPaths,
        argumentExtractor: &argumentExtractor
      )
    }
  }
#endif
