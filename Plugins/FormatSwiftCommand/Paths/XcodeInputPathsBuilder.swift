#if canImport(XcodeProjectPlugin)
  import PackagePlugin
  import XcodeProjectPlugin

  struct XcodeInputPathsBuilder {
    static func inputPaths(
      using argumentExtractor: inout ArgumentExtractor,
      context: XcodePluginContext
    ) throws -> [String] {
      let parsedArguments = ParsedArguments.parse(using: &argumentExtractor)
      let inputTargetNames = Set(parsedArguments.targets)

      let inputPaths = context.xcodeProject.targets.lazy
        .filter { inputTargetNames.contains($0.displayName) }
        .flatMap(\.inputFiles)
        .map(\.path.string)
        .filter { $0.hasSuffix(".swift") }

      return Array(inputPaths)
    }
  }

  private struct ParsedArguments: ArgumentParsable {
    let targets: [String]

    static func parse(
      using argumentExtractor: inout ArgumentExtractor
    ) -> ParsedArguments {
      ParsedArguments(
        // When ran from Xcode, the plugin command is invoked with `--target` arguments,
        // specifying the targets selected in the plugin dialog.
        //  - Unlike SPM targets which are just directories, Xcode targets are
        //    an arbitrary collection of paths.
        targets: argument("target", using: &argumentExtractor)
      )
    }
  }
#endif
