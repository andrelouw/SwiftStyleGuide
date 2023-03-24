import Foundation

extension Process {
  /// The shell command for the process.
  ///
  /// Returns the executable url and the arguments
  var shellCommand: String {
    let executableURL = executableURL?.absoluteString ?? ""
    let arguments = arguments ?? []
    return "\(executableURL) \(arguments.joined(separator: " "))"
  }
}
