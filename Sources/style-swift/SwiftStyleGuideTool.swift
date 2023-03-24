import ArgumentParser
import Foundation

/// Example command:
/// ```
/// swift run style --swift-format-path /opt/homebrew/bin/swiftformat --swift-format-config default.swiftformat --swift-lint-path /opt/homebrew/bin/swiftlint --swift-lint-config swiftlint.yml .
/// ```

@main
struct SwiftStyleGuideTool: ParsableCommand {
  @Argument(help: "The directories to format")
  var directories: [String]

  @Flag(help: "When true, logs the commands that are executed")
  var log = false

  @OptionGroup(title: "SwiftFormat")
  var swiftFormatOptions: SwiftFormat.Options

  @OptionGroup(title: "SwiftLint")
  var swiftLintOptions: SwiftLint.Options

  private lazy var processes: [ToolProcess] = [
    .swiftFormat(directories: directories, options: swiftFormatOptions),
    .swiftLint(directories: directories, options: swiftLintOptions)
  ]

  mutating func run() throws {
    log("Running style guide tool...")

    let results = try processes.map {
      try run(process: $0)
    }

    if results.exitCode > 0 {
      throw ExitCode(results.exitCode)
    }
  }

  private func run(process: ToolProcess) throws -> ProcessResult {
    if log {
      log(process.command)
    }

    let result = try process.run()

    if log {
      switch result {
      case .success:
        log("\(process.name) completed successfully")

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
