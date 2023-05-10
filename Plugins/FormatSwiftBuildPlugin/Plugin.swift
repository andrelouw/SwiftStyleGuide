//
//  File.swift
//
//
//  Created by Andre Louw on 19/03/2023.
//

import Foundation
import PackagePlugin

@main
struct FormatBuildPlugin: BuildToolPlugin {
  func createBuildCommands(
    context: PluginContext,
    target: Target
  ) throws -> [Command] {
    guard let sourceTarget = target as? SourceModuleTarget else {
      return []
    }

    let inputFiles = sourceTarget.sourceFiles(withSuffix: "swift").map(\.path)

    return try createBuildCommands(context: context, inputPaths: inputFiles)
  }

  private func createBuildCommands(
    context: CommandContext,
    inputPaths: [Path]
  ) throws -> [Command] {
    let tool = try context.tool(named: "style-swift")

    var arguments = [
      "--swift-lint-path", "/opt/homebrew/bin/swiftlint",
      "--swift-format-path", "/opt/homebrew/bin/swiftformat",
      "--log"
    ]

    arguments.append(contentsOf: inputPaths.map(\.string))

    return [
//      .buildCommand(
//        displayName: "FormatSwift",
//        executable: tool.path,
//        arguments: arguments
//      ),
      .prebuildCommand(
        displayName: "FormatSwift",
        executable: tool.path,
        arguments: arguments,
        outputFilesDirectory: context.workingDirectory.appending("Output")
      )
    ]
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension FormatBuildPlugin: XcodeBuildToolPlugin {
  func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
    let inputFilePaths = target.inputFiles
      .filter { $0.type == .source && $0.path.extension == "swift" }
      .map(\.path)

    return try createBuildCommands(context: context, inputPaths: inputFilePaths)
  }
}
#endif

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
