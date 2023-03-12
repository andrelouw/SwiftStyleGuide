import ArgumentParser
import Foundation

struct SwiftLint: StyleGuideTool {
  struct Options: ParsableArguments {
    @Option(help: "The absolute path to a SwiftLint binary")
    var swiftLintPath: String

    @Option(help: "The absolute path to the SwiftLint config file")
    var swiftLintConfig: String = Bundle.module.path(forResource: "swiftlint", ofType: "yml")!

    @Option(help: "The absolute path to use for SwiftLint's cache")
    var swiftLintCachePath: String?

    @Option(help: "When passed, source files are not reformatted")
    var swiftLintOnlyLint: Bool = false
  }

  let name = "SwiftLint"
  let executablePath: String
  let arguments: [String]

  init(
    directories: [String],
    options: Options
  ) {
    arguments = Self.argumentsParser(directories: directories, options: options)
    executablePath = options.swiftLintPath
  }

  func resultParser(_ result: Int32) -> ProcessResult {
    if result == SwiftLintExitCode.lintFailure {
      return .lintFailure
    }

    // Any other non-success exit code is an unknown failure
    if result != SwiftLintExitCode.success {
      return .error(result)
    }

    return .success
  }

  private static func argumentsParser(directories: [String], options: Options) -> [String] {
    var arguments = directories

    arguments += ["--config", options.swiftLintConfig]

    // Required for SwiftLint to emit a non-zero exit code on lint failure
    arguments += ["--strict"]
    arguments += ["--quiet"]

    if let cachePath = options.swiftLintCachePath {
      arguments += ["--cache-path", cachePath]
    }

    if !options.swiftLintOnlyLint {
      arguments += ["--fix"]
    }

    return arguments
  }
}

/// Known exit codes used by SwiftLint
private enum SwiftLintExitCode {
  static let success: Int32 = 0

  static let lintFailure: Int32 = 2
}
