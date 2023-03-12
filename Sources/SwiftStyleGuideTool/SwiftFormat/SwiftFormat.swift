import ArgumentParser
import Foundation

struct SwiftFormat: StyleGuideTool {
  struct Options: ParsableArguments {
    @Option(help: "The absolute path to a SwiftFormat binary")
    var swiftFormatPath: String

    @Option(help: "The absolute path to the SwiftFormat config file")
    var swiftFormatConfig: String?

    @Option(help: "The absolute path to use for SwiftFormat's cache")
    var swiftFormatCachePath: String?

    @Option(help: "When passed, source files are not reformatted")
    var swiftFormatOnlyLint: Bool = false

    @Option(help: "The project's minimum Swift version")
    var swiftVersion: String?
  }

  let name = "SwiftFormat"
  let executablePath: String
  let arguments: [String]

  init(
    directories: [String],
    options: Options
  ) {
    arguments = Self.argumentsParser(directories: directories, options: options)
    executablePath = options.swiftFormatPath
  }

  func resultParser(_ result: Int32) -> ProcessResult {
    if result == SwiftFormatExitCode.lintFailure {
      return .lintFailure
    }

    // Any other non-success exit code is an unknown failure
    if result != SwiftFormatExitCode.success {
      return .error(result)
    }

    return .success
  }

  private static func argumentsParser(directories: [String], options: Options) -> [String] {
    var arguments = directories

    if let config = options.swiftFormatConfig {
      arguments += ["--config", config]
    }

    if let cachePath = options.swiftFormatCachePath {
      arguments += ["--cache", cachePath]
    }

    if options.swiftFormatOnlyLint {
      arguments += ["--lint"]
    }

    if let swiftVersion = options.swiftVersion {
      arguments += ["--swiftversion", swiftVersion]
    }

    return arguments
  }
}

/// Known exit codes used by SwiftFormat
private enum SwiftFormatExitCode {
  /// This code will be returned in the event of a successful formatting run or if `--lint` detects no violations.
  static let success: Int32 = 0

  /// This code will be returned only when running in `--lint` mode if the input requires formatting.
  static let lintFailure: Int32 = 1

  /// This code will be returned if there is a problem with the input or configuration arguments.
  static let programError: Int32 = 70
}
