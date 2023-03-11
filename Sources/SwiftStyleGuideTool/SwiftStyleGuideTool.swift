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

  private lazy var swiftFormat = SwiftFormat(
    path: swiftFormatPath,
    directories: directories,
    config: swiftFormatConfig,
    cachePath: swiftFormatCachePath,
    onlyLint: lint,
    swiftVersion: swiftVersion
  ).process

  mutating func run() throws {
    log("Running style guide tool...")
    try swiftFormat.run()
    swiftFormat.waitUntilExit()

    if log {
      log(swiftFormat.shellCommand)
      log("SwiftFormat ended with exit code \(swiftFormat.terminationStatus)")
    }

    if swiftFormat.terminationStatus == SwiftFormatExitCode.lintFailure {
      throw ExitCode.failure
    }

    // Any other non-success exit code is an unknown failure
    if swiftFormat.terminationStatus != EXIT_SUCCESS {
      throw ExitCode(swiftFormat.terminationStatus)
    }
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

/// Known exit codes used by SwiftFormat
enum SwiftFormatExitCode {
  /// This code will be returned in the event of a successful formatting run or if `--lint` detects no violations.
  static let success: Int32 = 0

  /// This code will be returned only when running in `--lint` mode if the input requires formatting.
  static let lintFailure: Int32 = 1

  /// This code will be returned if there is a problem with the input or configuration arguments.
  static let programError: Int32 = 70
}
