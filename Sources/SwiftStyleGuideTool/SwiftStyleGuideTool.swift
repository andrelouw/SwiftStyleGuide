import ArgumentParser
import Foundation

@main
struct SwiftStyleGuideTool: ParsableCommand {
  @Argument(help: "The directories to format")
  var directories: [String]

  // MARK: Swift Format

  @Option(help: "The absolute path to a SwiftFormat binary")
  var swiftFormatPath: String

  @Option(help: "The absolute path to the SwiftFormat config file")
  var swiftFormatConfig = Bundle.module.path(forResource: "default", ofType: "swiftformat")!

  mutating func run() throws {
    log("Running style guide tool...")
    try swiftFormat.run()
    swiftFormat.waitUntilExit()
  }

  private lazy var swiftFormat: Process = {
    var arguments = directories + [
      "--config", swiftFormatConfig,
    ]

    let swiftFormat = Process()
    swiftFormat.executableURL = URL(filePath: swiftFormatPath)
    swiftFormat.arguments = arguments
    return swiftFormat
  }()

  private func log(_ string: String) {
    print("[SwiftStyleGuideTool]", string)
  }
}
