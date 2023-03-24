struct Arguments {
  private var arguments: [Argument] = []

  init(_ arguments: [Argument] = []) {
    self.arguments = arguments
  }

  mutating func add(_ argument: Argument) {
    arguments.append(argument)
  }

  mutating func addIfNotNil(_ argument: Argument?) {
    if let argument {
      add(argument)
    }
  }

  func asStringArray() -> [String] {
    arguments.flatMap { $0.asStringArray() }
  }
}
