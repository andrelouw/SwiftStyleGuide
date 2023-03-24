import ArgumentParser

protocol StyleGuideTool {
  associatedtype Options: ParsableArguments

  var name: String { get }
  var executablePath: String { get }
  var arguments: [String] { get }

  func resultParser(_ result: Int32) -> ProcessResult
}

extension StyleGuideTool {
  func asToolProcess() -> ToolProcess {
    ToolProcess(
      name: name,
      executablePath: executablePath,
      arguments: arguments,
      resultParser: resultParser
    )
  }
}
