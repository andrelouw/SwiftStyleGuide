import Foundation

struct SwiftFormat {
  let path: String
  let directories: [String]
  let config: String
  let cachePath: String?
  let onlyLint: Bool
  let swiftVersion: String?

  var process: Process {
    let swiftFormat = Process()
    swiftFormat.executableURL = URL(filePath: path)
    swiftFormat.arguments = arguments
    return swiftFormat
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
}
