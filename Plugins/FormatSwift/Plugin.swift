import Foundation
import PackagePlugin

@main
struct FormatSwift: CommandPlugin {
  func performCommand(
    context: PluginContext,
    arguments: [String]
  ) async throws {
    // Path options:
    // - Add specific paths using `--paths`
    // - Add specific targets using `--targets`
    // - defaults to running on whole directory (by using input paths helper)
    let inputPaths = try inputPaths(for: context.package)

//    let workingDirectory = context.package.directory
//    let swiftLintConfigFilePath = workingDirectory.appending("swiftlint.yml").string
//    let swiftFormatConfigFilePath = workingDirectory.appending("swiftformat").string

    let launchPath = try context.tool(named: "SwiftStyleGuideTool").path.string

    var toolArguments = inputPaths

    toolArguments += [
      "--swift-format-path", "/opt/homebrew/bin/swiftformat",
//      "--swift-format-config", swiftFormatConfigFilePath,
      "--swift-lint-path", "/opt/homebrew/bin/swiftlint",
//      "--swift-lint-config", swiftLintConfigFilePath,
      "--swift-format-cache-path",
      context.pluginWorkDirectory.string + "/swiftformat.cache",
      "--swift-lint-cache-path",
      context.pluginWorkDirectory.string + "/swiftlint.cache",
      "--log", "--swift-lint-only-lint", "--swift-format-only-lint"
    ]

    let process = Process()
    process.launchPath = launchPath
    process.arguments = toolArguments
    try process.run()

    process.waitUntilExit()

    switch process.terminationStatus {
    case EXIT_SUCCESS:
      break
    default:
      throw CommandError.unknownError(exitCode: process.terminationStatus)
    }
  }

  /// Retrieves the list of paths that should be formatted / linted
  ///
  /// By default this tool runs on all subdirectories of the package's root directory,
  /// plus any Swift files directly contained in the root directory. This is a
  /// workaround for two interesting issues:
  ///  - If we lint `content.package.directory`, then SwiftLint lints the `.build` subdirectory,
  ///    which includes checkouts for any SPM dependencies, even if we add `.build` to the
  ///    `excluded` configuration in our `swiftlint.yml`.
  ///  - We could lint `context.package.targets.map { $0.directory }`, but that excludes
  ///    plugin targets, which include Swift code that we want to lint.
  private func inputPaths(for package: Package) throws -> [String] {
    let packageDirectoryContents = try FileManager.default.contentsOfDirectory(
      at: URL(fileURLWithPath: package.directory.string),
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles])

    let subdirectories = packageDirectoryContents.filter { $0.hasDirectoryPath }
    let rootSwiftFiles = packageDirectoryContents.filter { $0.pathExtension.hasSuffix("swift") }
    return (subdirectories + rootSwiftFiles).map { $0.path }
  }
}

enum CommandError: Error {
  case lintFailure
  case unknownError(exitCode: Int32)
}
