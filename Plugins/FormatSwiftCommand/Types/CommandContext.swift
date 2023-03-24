import Foundation
import PackagePlugin

/// Shared methods implemented by `PluginContext` and `XcodePluginContext`
protocol CommandContext {
  var pluginWorkDirectory: Path { get }
  var workingDirectory: Path { get }
  var swiftVersion: String? { get }

  func tool(named name: String) throws -> PluginContext.Tool
}

// MARK: - PluginContext + CommandContext

extension PluginContext: CommandContext {
  var workingDirectory: Path {
    package.directory
  }

  var swiftVersion: String? {
    "\(package.toolsVersion.major).\(package.toolsVersion.minor)"
  }
}

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension XcodePluginContext: CommandContext {
    var workingDirectory: Path {
      xcodeProject.directory
    }

    var swiftVersion: String? {
      // TODO: Find .swift-version file in working directory and return the version specified
      nil
    }
  }
#endif
