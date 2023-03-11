import ArgumentParser
import Foundation

@main
struct SwiftStyleGuideTool: ParsableCommand {
  func run() throws {
    log("Hello style tool!")
  }

  private func log(_ string: String) {
    print("[SwiftStyleGuideTool]", string)
  }
}
