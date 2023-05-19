import ArgumentParser
import Foundation

struct SwiftFormat: StyleGuideTool {
  struct Options: ParsableArguments {
    @Option(help: "The absolute path to a SwiftFormat binary")
    var swiftFormatPath: String

    @Option(help: "The absolute path to the SwiftFormat config file")
    var swiftFormatConfig: String = Bundle.module.path(forResource: "swiftformat", ofType: "config")!

    @Option(help: "The absolute path to use for SwiftFormat's cache")
    var swiftFormatCachePath: String?

    @Flag(help: "When passed, source files are not reformatted")
    var swiftFormatLintOnly: Bool = false

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

  func resultParser(_ result: ToolProcessResult) -> ProcessResult {
    if result.terminationStatus == SwiftFormatExitCode.lintFailure {
      var lintWarnings = result.stderr?.components(separatedBy: .newlines) ?? []
      lintWarnings = lintWarnings.filter {
        ["warning", "error"].contains(where: $0.contains)
      }

      return .lintFailure(lintWarnings)
    }

    // Any other non-success exit code is an unknown failure
    if result.terminationStatus != SwiftFormatExitCode.success {
      return .error(result.terminationStatus, result.stderr)
    }

    return .success(result.stdout)
  }

  private static func argumentsParser(directories: [String], options: Options) -> [String] {
    var arguments = directories

    arguments += ["--config", options.swiftFormatConfig]

    if let cachePath = options.swiftFormatCachePath {
      arguments += ["--cache", cachePath]
    }

    if options.swiftFormatLintOnly {
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
