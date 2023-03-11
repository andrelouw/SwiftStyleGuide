enum ProcessResult: Equatable {
  case success
  case lintFailure
  case error(Int32)

  var exitCode: Int32 {
    switch self {
    case .success:
      return 0

    case .lintFailure:
      return 1

    case let .error(error):
      return error
    }
  }
}

extension [ProcessResult] {
  var exitCode: Int32 {
    if let error = errors.first {
      return error
    }

    if contains(.lintFailure) {
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
