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
      switch result {
      case .success:
        log("\(process.name) completed with successfully")

      case .lintFailure:
        log("\(process.name) failed due to linting failure")

      case let .error(exitCode):
        log("\(process.name) failed with exit code: \(exitCode)")
      }
    }

    return result
  }

  private func log(_ string: String) {
    print("[SwiftStyleGuideTool]", string)
  }
}
