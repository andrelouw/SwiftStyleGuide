import PackagePlugin

#if os(Linux)
  import Glibc
#else
  import Darwin
#endif

extension Path {
  /// Scans the receiver, then all of its parents looking for a configuration file with the name ".swiftlint.yml".
  ///
  /// - returns: Path to the configuration file, or nil if one cannot be found.
  func firstFileInParentDirectories(named fileName: String) -> Path? {
    let proposedDirectory = sequence(
      first: self,
      next: { path in
        guard path.stem.count > 1 else {
          // Check we're not at the root of this filesystem, as `removingLastComponent()`
          // will continually return the root from itself.
          return nil
        }

        return path.removingLastComponent()
      }
    ).first { path in
      let potentialMatch = path.appending(subpath: fileName)
      return potentialMatch.isAccessible()
    }
    return proposedDirectory?.appending(subpath: fileName)
  }

  /// Safe way to check if the file is accessible from within the current process sandbox.
  private func isAccessible() -> Bool {
    let result = string.withCString { pointer in
      access(pointer, R_OK)
    }

    return result == 0
  }
}
