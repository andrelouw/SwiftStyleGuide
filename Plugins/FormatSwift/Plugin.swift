import Foundation
import PackagePlugin

@main
struct FormatSwift: CommandPlugin {
  func performCommand(
    context: PluginContext,
    arguments _: [String]
  ) async throws {
    // Path options:
    // - Add specific paths using `--paths`
    // - Add specific targets using `--targets`
    // - defaults to running on whole directory
    let workingDirectory = context.package.directory
    let swiftLintConfigFilePath = workingDirectory.appending("swiftlint.yml").string
    let swiftFormatConfigFilePath = workingDirectory.appending("swiftformat").string

    let launchPath = try context.tool(named: "SwiftStyleGuideTool").path.string

    var arguments = [workingDirectory.string]

    arguments += [
      "--swift-format-path", "/opt/homebrew/bin/swiftformat",
      "--swift-format-config", swiftFormatConfigFilePath,
      "--swift-lint-path", "/opt/homebrew/bin/swiftlint",
      "--swift-lint-config", swiftLintConfigFilePath,
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
