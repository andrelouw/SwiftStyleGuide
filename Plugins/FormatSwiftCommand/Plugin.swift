import Foundation
import PackagePlugin

@main
struct FormatSwiftCommand: CommandPlugin {
  func performCommand(context: PluginContext, arguments externalArguments: [String]) async throws {
    let styleSwift = try context.tool(named: "style-swift")
    let argumentBuilders: [ArgumentBuildable] = [.paths, .swiftFormat, .swiftLint]
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

// struct FormatSwift: CommandPlugin {
//  func performCommand(
//    context: PluginContext,
//    arguments: [String]
//  ) async throws {
//    var argumentExtractor = ArgumentExtractor(arguments)
//    let paths = try determinePaths(&argumentExtractor, context)
//    let toolArguments = toolArguments(from: paths, &argumentExtractor, context)
//    let launchPath = try context.tool(named: "style-swift").path.string
//
//    let process = Process()
//    process.launchPath = launchPath
//    process.arguments = toolArguments
//    try process.run()
//
//    process.waitUntilExit()
//
//    switch process.terminationStatus {
//    case EXIT_SUCCESS:
//      break
//    default:
//      throw CommandError.unknownError(exitCode: process.terminationStatus)
//    }
//  }
//
//  private func toolArguments(
//    from paths: [String],
//    _ argumentExtractor: inout ArgumentExtractor,
//    _ context: PluginContext
//  ) -> [String] {
//    var arguments = paths
//
//    // To get config files in package root
//    //    let workingDirectory = context.package.directory
//    //    let swiftLintConfigFilePath = workingDirectory.appending("swiftlint.yml").string
//    //    let swiftFormatConfigFilePath = workingDirectory.appending("swiftformat").string
//
//    arguments += [
//      "--swift-format-path", "/opt/homebrew/bin/swiftformat",
//      //      "--swift-format-config", swiftFormatConfigFilePath,
//      "--swift-lint-path", "/opt/homebrew/bin/swiftlint",
//      //      "--swift-lint-config", swiftLintConfigFilePath,
//      "--swift-format-cache-path",
//      context.pluginWorkDirectory.string + "/swiftformat.cache",
//      "--swift-lint-cache-path",
//      context.pluginWorkDirectory.string + "/swiftlint.cache"
//    ]
//
//    arguments += configFileArguments(&argumentExtractor, context)
//
//    if shouldOnlyLint(&argumentExtractor) {
//      arguments += ["--swift-lint-only-lint", "--swift-format-only-lint"]
//    }
//
//    if shouldLog(&argumentExtractor) {
//      arguments += ["--log"]
//    }
//
//    arguments += ["--swift-version", swiftVersion(&argumentExtractor, context)]
//
//    arguments += argumentExtractor.remainingArguments
//
//    return arguments
//  }
//
//  private func configFileArguments(
//    _ argumentExtractor: inout ArgumentExtractor,
//    _ context: PluginContext
//  ) -> [String] {
//    let packageDirectory = context.package.directory
//    var arguments = [String]()
//
//    if let configFile = argumentExtractor.extractOption(named: "swift-lint-config").last {
//      arguments.append(contentsOf: ["--swift-lint-config", configFile])
//    } else if let swiftLintConfigPath = packageDirectory.firstFileInParentDirectories(named: "swiftlint.yml") {
//      arguments.append(contentsOf: ["--swift-lint-config", swiftLintConfigPath.string])
//    }
//
//    if let configFile = argumentExtractor.extractOption(named: "swift-format-config").last {
//      arguments.append(contentsOf: ["--swift-format-config", configFile])
//    } else if let swiftFormatConfigPath = packageDirectory.firstFileInParentDirectories(named: "swiftformat") {
//      arguments.append(contentsOf: ["--swift-format-config", swiftFormatConfigPath.string])
//    }
//
//    return arguments
//  }
//
//  private func swiftVersion(_ argumentExtractor: inout ArgumentExtractor, _ context: PluginContext) -> String {
//    // When running on a SPM package we infer the minimum Swift version from the
//    // `swift-tools-version` in `Package.swift` by default if the user doesn't
//    // specify one manually
//    argumentExtractor.extractOption(named: "swift-version").last
//      ?? "\(context.package.toolsVersion.major).\(context.package.toolsVersion.minor)"
//  }
//
//  private func shouldLog(_ argumentExtractor: inout ArgumentExtractor) -> Bool {
//    argumentExtractor.extractFlag(named: "log") > 0
//  }
//
//  private func shouldOnlyLint(_ argumentExtractor: inout ArgumentExtractor) -> Bool {
//    argumentExtractor.extractFlag(named: "lint") > 0
//  }
//
//  private func determinePaths(_ argumentExtractor: inout ArgumentExtractor, _ context: PluginContext) throws -> [String] {
//    // When ran from Xcode, the plugin command is invoked with `--target` arguments,
//    // specifying the targets selected in the plugin dialog.
//    let inputTargets = argumentExtractor.extractOption(named: "target")
//
//    // If given, lint only the paths passed to `--paths`
//    var paths = argumentExtractor.extractOption(named: "paths")
//
//    if !inputTargets.isEmpty {
//      // If a set of input targets were given, lint/format the directory for each of them
//      paths += try context.package.targets(named: inputTargets).map(\.directory.string)
//    } else if paths.isEmpty {
//      // Otherwise if no targets or paths listed we default to linting/formatting
//      // the entire package directory.
//      paths = try allPaths(for: context.package)
//    }
//
//    return paths
//  }
//
//  /// Retrieves the list of paths that should be formatted / linted
//  ///
//  /// By default this tool runs on all subdirectories of the package's root directory,
//  /// plus any Swift files directly contained in the root directory. This is a
//  /// workaround for two interesting issues:
//  ///  - If we lint `content.package.directory`, then SwiftLint lints the `.build` subdirectory,
//  ///    which includes checkouts for any SPM dependencies, even if we add `.build` to the
//  ///    `excluded` configuration in our `swiftlint.yml`.
//  ///  - We could lint `context.package.targets.map { $0.directory }`, but that excludes
//  ///    plugin targets, which include Swift code that we want to lint.
//  private func allPaths(for package: Package) throws -> [String] {
//    let packageDirectoryContents = try FileManager.default.contentsOfDirectory(
//      at: URL(fileURLWithPath: package.directory.string),
//      includingPropertiesForKeys: nil,
//      options: [.skipsHiddenFiles]
//    )
//
//    let subdirectories = packageDirectoryContents.filter(\.hasDirectoryPath)
//    let rootSwiftFiles = packageDirectoryContents.filter { $0.pathExtension.hasSuffix("swift") }
//    return (subdirectories + rootSwiftFiles).map(\.path)
//  }
// }
//
// enum CommandError: Error {
//  case lintFailure
//  case unknownError(exitCode: Int32)
// }
//
//
