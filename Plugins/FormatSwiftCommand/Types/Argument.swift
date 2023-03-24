struct Argument {
  let name: String
  let value: String?

  func asStringArray() -> [String] {
    var array = ["--\(name)"]
    if let value {
      array.append(value)
    }

    return array
  }
}
