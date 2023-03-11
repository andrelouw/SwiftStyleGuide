protocol StyleGuideToolProcess {
  var name: String { get }
  var command: String { get }

  func run() throws -> ProcessResult
}
