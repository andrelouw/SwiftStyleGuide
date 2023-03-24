// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftStyleGuide",
  platforms: [.macOS(.v13)],
  products: [
    .executable(name: "style-swift", targets: ["style-swift"]),
    .plugin(name: "FormatSwift", targets: ["FormatSwiftCommand"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.3")
  ],
  targets: [
    .executableTarget(
      name: "style-swift",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .plugin(
      name: "FormatSwiftCommand",
      capability: .command(
        intent: .custom(
          verb: "format",
          description: "Formats Swift source files according to the Swift Style Guide"
        ),
        permissions: [
          .writeToPackageDirectory(reason: "Format Swift source files")
        ]
      ),
      dependencies: [
        .target(name: "style-swift")
      ]
    )
  ]
)
