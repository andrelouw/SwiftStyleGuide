enum ProcessResult: Equatable {
  case success(String?)
  case lintFailure([String])
  case error(Int32, String?)

  static let lintFailure = Self.lintFailure([])
  static let success = Self.success("")

  var exitCode: Int32 {
    switch self {
    case .success:
      return 0

    case .lintFailure:
      return 1

    case let .error(error, _):
      return error
    }
  }
}

extension ProcessResult {
  static func ~= (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.lintFailure, .lintFailure),
         (.success, .success),
         (.error, .error):
      return true

    default:
      return false
    }
  }
}

extension [ProcessResult] {
  var exitCode: Int32 {
    if let error = errors.first {
      return error
    }

    if contains(where: {
      $0 ~= .lintFailure
    }) {
      return ProcessResult.lintFailure.exitCode
    }

    return ProcessResult.success.exitCode
  }

  private var errors: [Int32] {
    compactMap { result in
      if case .error = result {
        return result.exitCode
      }

      return nil
    }
  }
}
