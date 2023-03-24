import PackagePlugin
import Foundation

extension ArgumentBuildable where Self == PathArgumentBuilder {
  static var paths: Self { PathArgumentBuilder() }
}

struct PathArgumentBuilder: ArgumentBuildable {
  func arguments(
      using argumentExtractor: inout ArgumentExtractor,
      context: PluginContext
  ) throws -> [String] {
    let parsedArguments = ParsedArguments.parse(using: &argumentExtractor)

    var paths = parsedArguments.paths

    if !parsedArguments.targets.isEmpty {
      // If a set of input targets were given, lint/format the directory for each of them
      paths += try context.package.targets(named: parsedArguments.targets).map(\.directory.string)
    } else if paths.isEmpty {
      // Otherwise if no targets or paths listed we default to linting/formatting
      // the entire package directory.
      paths = try allPaths(for: context.package)
    }

    return paths
  }

  /// Retrieves the list of paths that should be formatted / linted
  ///
  /// By default this tool runs on all subdirectories of the package's root directory,
  /// plus any Swift files directly contained in the root directory. This is a
  /// workaround for two interesting issues:
  ///  - If we lint/format `content.package.directory`, then we include the `.build` subdirectory,
  ///    which includes checkouts for any SPM dependencies, even if we add `.build` to the
  ///    `excluded` configuration in our `swiftlint.yml` or `swiftformat`.
  ///  - We could lint/format `context.package.targets.map { $0.directory }`, but that excludes
  ///    plugin targets, which include Swift code that we want to lint/format.
  private func allPaths(for package: Package) throws -> [String] {
    let packageDirectoryContents = try FileManager.default.contentsOfDirectory(
        at: URL(fileURLWithPath: package.directory.string),
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
    )

    let subdirectories = packageDirectoryContents.filter(\.hasDirectoryPath)
    let rootSwiftFiles = packageDirectoryContents.filter { $0.pathExtension.hasSuffix("swift") }
    return (subdirectories + rootSwiftFiles).map(\.path)
  }
}

private struct ParsedArguments: ArgumentParsable {
  let targets: [String]
  let paths: [String]

  static func parse(
      using argumentExtractor: inout ArgumentExtractor
  ) -> ParsedArguments {
    ParsedArguments(
        // When ran from Xcode, the plugin command is invoked with `--target` arguments,
        // specifying the targets selected in the plugin dialog.
        targets: argument("target", using: &argumentExtractor),
        paths: argument("paths", using: &argumentExtractor)
    )
  }
}
