// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftStyleGuide",
  platforms: [.macOS(.v13)],
  products: [
    .executable(name: "style", targets: ["SwiftStyleGuideTool"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.3"),
  ],
  targets: [
    .executableTarget(
      name: "SwiftStyleGuideTool",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      resources: [
        .process("default.swiftformat"),
      ]
    ),
  ]
)
