import ArgumentParser
import Foundation

/// Example command:
/// ```
/// swift run style --swift-format-path /opt/homebrew/bin/swiftformat --swift-format-cache-path  "swiftformat.cache" .
/// ```
///
/// To only lint:
/// ```
/// swift run style --swift-format-path /opt/homebrew/bin/swiftformat --swift-format-cache-path  "swiftformat.cache" --lint .
/// ```

@main
struct SwiftStyleGuideTool: ParsableCommand {
  @Argument(help: "The directories to format")
  var directories: [String]

  @Flag(help: "When passed, source files are not reformatted")
  var lint = false

  @Option(help: "The project's minimum Swift version")
  var swiftVersion: String?

  @Flag(help: "When true, logs the commands that are executed")
  var log = false

  // MARK: Swift Format

  @Option(help: "The absolute path to a SwiftFormat binary")
  var swiftFormatPath: String

  @Option(help: "The absolute path to the SwiftFormat config file")
  var swiftFormatConfig = Bundle.module.path(forResource: "default", ofType: "swiftformat")!

  @Option(help: "The absolute path to use for SwiftFormat's cache")
  var swiftFormatCachePath: String?

  private lazy var processes: [StyleGuideToolProcess] = [swiftFormat]

  private lazy var swiftFormat = SwiftFormat(
    path: swiftFormatPath,
    directories: directories,
    config: swiftFormatConfig,
    cachePath: swiftFormatCachePath,
    onlyLint: lint,
    swiftVersion: swiftVersion
  )

  mutating func run() throws {
    log("Running style guide tool...")

    let results = try processes.map {
      try run(process: $0)
    }

    if results.exitCode > 0 {
      throw ExitCode(results.exitCode)
    }
  }

  private func run(process: StyleGuideToolProcess) throws -> ProcessResult {
    if log {
      log(process.command)
    }

    let result = try process.run()

    if log {
      log("\(process.name) ended with exit code `\(result)`")
    }

    return result
  }

  private func log(_ string: String) {
    print("[SwiftStyleGuideTool]", string)
  }
}

extension Process {
  /// The shell command for the process.
  ///
  /// Returns the executable url and the arguments
  var shellCommand: String {
    let executableURL = executableURL?.absoluteString ?? ""
    let arguments = arguments ?? []
    return "\(executableURL) \(arguments.joined(separator: " "))"
  }
}

extension [ProcessResult] {
  var exitCode: Int32 {
    if let error = errors.first {
      return error
    }

    if contains(.lintFailure) {
      return ProcessResult.lintFailure.exitCode
    }

    return ProcessResult.success.exitCode
  }

  private var errors: [Int32] {
    compactMap { result in
      if case .error = result {
        return result.exitCode
      }

      return nil
    }
  }
}

enum ProcessResult: Equatable {
  case success
  case lintFailure
  case error(Int32)

  var exitCode: Int32 {
    switch self {
    case .success:
      return 0

    case .lintFailure:
      return 1

    case let .error(error):
      return error
    }
  }
}
