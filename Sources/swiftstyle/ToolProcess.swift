//
//  File.swift
//
//
//  Created by Andre Louw on 12/03/2023.
//

import Foundation

struct ToolProcessResult {
  let terminationStatus: Int32
  let stdout: String?
  let stderr: String?
}

final class ToolProcess {
  typealias ResultParser = (ToolProcessResult) -> ProcessResult

  struct RunError: Error {
    let terminationStatus: Int32
    let description: String
  }

  private let executablePath: String
  private let arguments: [String]
  private let resultParser: ResultParser

  let name: String
  var command: String { process.shellCommand }

  private lazy var process: Process = {
    let process = Process()

    process.executableURL = URL(fileURLWithPath: executablePath)
    process.arguments = arguments
    // TODO: Pass environment
    process.environment = nil
    process.standardError = stderrPipe
    process.standardOutput = stdoutPipe

    return process
  }()

  private lazy var stderrPipe = Pipe()
  private lazy var stdoutPipe = Pipe()

  init(
    name: String,
    executablePath: String,
    arguments: [String],
    resultParser: @escaping ResultParser
  ) {
    self.name = name
    self.resultParser = resultParser
    self.arguments = arguments
    self.executablePath = executablePath
  }

  func run() throws -> ProcessResult {
    try process.run()
    process.waitUntilExit()

    let output = try stdoutPipe.fileHandleForReading.readToEnd()
    let stdout = output.flatMap { String(data: $0, encoding: .utf8) }

    let error = try stderrPipe.fileHandleForReading.readToEnd()
    let stderr = error.flatMap { String(data: $0, encoding: .utf8) }

    let result = ToolProcessResult(
      terminationStatus: process.terminationStatus,
      stdout: stdout,
      stderr: stderr
    )

    return resultParser(result)
  }
}
