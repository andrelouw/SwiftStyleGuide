import Foundation

final class SwiftLint: StyleGuideToolProcess {
  private let path: String
  private let directories: [String]
  private let config: String
  private let cachePath: String?
  private let shouldFix: Bool

  let name = "SwiftLint"

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
    shouldFix: Bool
  ) {
    self.path = path
    self.directories = directories
    self.config = config
    self.cachePath = cachePath
    self.shouldFix = shouldFix
  }

  func run() throws -> ProcessResult {
    try process.run()
    process.waitUntilExit()

    if process.terminationStatus == SwiftLintExitCode.lintFailure {
      return .lintFailure
    }

    // Any other non-success exit code is an unknown failure
    if process.terminationStatus != SwiftLintExitCode.success {
      return .error(process.terminationStatus)
    }

    return .success
  }

  private var arguments: [String] {
    var arguments = directories

    arguments += ["--config", config]

    // Required for SwiftLint to emit a non-zero exit code on lint failure
    arguments += ["--strict"]
    arguments += ["--quiet"]

    if let cachePath {
      arguments += ["--cache-path", cachePath]
    }

    if shouldFix {
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
