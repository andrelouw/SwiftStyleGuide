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

  // MARK: Swift Format

  @Option(help: "The absolute path to a SwiftFormat binary")
  var swiftFormatPath: String

  @Option(help: "The absolute path to the SwiftFormat config file")
  var swiftFormatConfig = Bundle.module.path(forResource: "default", ofType: "swiftformat")!

  @Option(help: "The absolute path to use for SwiftFormat's cache")
  var swiftFormatCachePath: String?

  mutating func run() throws {
    log("Running style guide tool...")
    try swiftFormat.run()
    swiftFormat.waitUntilExit()
  }

  private lazy var swiftFormat: Process = {
    var arguments = directories

    arguments += ["--config", swiftFormatConfig]

    if let swiftFormatCachePath {
      arguments += ["--cache", swiftFormatCachePath]
    }

    if lint {
      arguments += ["--lint"]
    }

    if let swiftVersion = swiftVersion {
      arguments += ["--swiftversion", swiftVersion]
    }

    let swiftFormat = Process()
    swiftFormat.executableURL = URL(filePath: swiftFormatPath)
    swiftFormat.arguments = arguments
    return swiftFormat
  }()

  private func log(_ string: String) {
    print("[SwiftStyleGuideTool]", string)
  }





}
