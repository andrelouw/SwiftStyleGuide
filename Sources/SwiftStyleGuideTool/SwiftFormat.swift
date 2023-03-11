import Foundation

protocol StyleGuideToolProcess {
  var name: String { get }
  var command: String { get }

  func run() throws -> ProcessResult
}

final class SwiftFormat: StyleGuideToolProcess {
  let name = "SwiftFormat"

  let path: String
  let directories: [String]
  let config: String
  let cachePath: String?
  let onlyLint: Bool
  let swiftVersion: String?

  var command: String {
    process.shellCommand
  }

  private lazy var process: Process = {
    let swiftFormat = Process()
    swiftFormat.executableURL = URL(filePath: path)
    swiftFormat.arguments = arguments
    return swiftFormat
  }()

  init(
    path: String,
    directories: [String],
    config: String,
    cachePath: String?,
    onlyLint: Bool,
    swiftVersion: String?
  ) {
    self.path = path
    self.directories = directories
    self.config = config
    self.cachePath = cachePath
    self.onlyLint = onlyLint
    self.swiftVersion = swiftVersion
  }

  private var arguments: [String] {
    var arguments = directories

    arguments += ["--config", config]

    if let cachePath {
      arguments += ["--cache", cachePath]
    }

    if onlyLint {
      arguments += ["--lint"]
    }

    if let swiftVersion {
      arguments += ["--swiftversion", swiftVersion]
    }

    return arguments
  }

  func run() throws -> ProcessResult {
    try process.run()
    process.waitUntilExit()

    if process.terminationStatus == SwiftFormatExitCode.lintFailure {
      return .lintFailure
    }

    // Any other non-success exit code is an unknown failure
    if process.terminationStatus != SwiftFormatExitCode.success {
      return .error(process.terminationStatus)
    }

    return .success
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
