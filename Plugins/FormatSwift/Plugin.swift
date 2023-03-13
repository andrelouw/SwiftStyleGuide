import Foundation
import PackagePlugin

@main
struct FormatSwift: CommandPlugin {
  func performCommand(
    context: PluginContext,
    arguments _: [String]
  ) async throws {
    let targets = context.package.targets

    let directories = targets.map { $0.directory.string }

    let launchPath = try context.tool(named: "SwiftStyleGuideTool").path.string

    var arguments = directories

    arguments += [
      "--swift-format-path", "/opt/homebrew/bin/swiftformat",
      "--swift-lint-path", "/opt/homebrew/bin/swiftlint",
      "--swift-format-cache-path",
      context.pluginWorkDirectory.string + "/swiftformat.cache",
      "--swift-lint-cache-path",
      context.pluginWorkDirectory.string + "/swiftlint.cache",
      "--log", "--swift-lint-only-lint", "--swift-format-only-lint"
    ]

    let process = Process()
    process.launchPath = launchPath
    process.arguments = arguments
    try process.run()

    process.waitUntilExit()

    switch process.terminationStatus {
    case EXIT_SUCCESS:
      break
    default:
      throw CommandError.unknownError(exitCode: process.terminationStatus)
    }
  }
}

enum CommandError: Error {
  case lintFailure
  case unknownError(exitCode: Int32)
}
