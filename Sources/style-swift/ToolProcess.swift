//
//  File.swift
//
//
//  Created by Andre Louw on 12/03/2023.
//

import Foundation

final class ToolProcess {
  private let executablePath: String
  private let arguments: [String]
  private let resultParser: (Int32) -> ProcessResult

  let name: String
  var command: String { process.shellCommand }

  private lazy var process: Process = {
    let process = Process()
    process.executableURL = URL(filePath: executablePath)
    process.arguments = arguments
    return process
  }()

  init(
    name: String,
    executablePath: String,
    arguments: [String],
    resultParser: @escaping (Int32) -> ProcessResult
  ) {
    self.name = name
    self.resultParser = resultParser
    self.arguments = arguments
    self.executablePath = executablePath
  }

  func run() throws -> ProcessResult {
    try process.run()
    process.waitUntilExit()

    return resultParser(process.terminationStatus)
  }
}
