import Foundation
import PackagePlugin

extension PluginContext.Tool {
  struct RunError: Error {
    let terminationStatus: Int32
    let description: String
  }

  func run(arguments: [String], environment: [String: String]? = nil) throws {
    let pipe = Pipe()
    let process = Process()

    process.executableURL = URL(fileURLWithPath: path.string)
    process.arguments = arguments
    process.environment = environment
    process.standardError = pipe

    try process.run()
    process.waitUntilExit()

    if process.terminationReason == .exit, process.terminationStatus == 0 {
      return
    }

    let data = try pipe.fileHandleForReading.readToEnd()
    let stderr = data.flatMap { String(data: $0, encoding: .utf8) }

    if let stderr {
      throw RunError(terminationStatus: process.terminationStatus, description: stderr)
    } else {
      let problem = "\(process.terminationReason.rawValue):\(process.terminationStatus)"
      let message = "\(name) invocation failed: \(problem)"
      throw RunError(terminationStatus: process.terminationStatus, description: message)
    }
  }
}
