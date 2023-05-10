// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftStyleGuide",
  platforms: [.macOS(.v13)],
  products: [
    .executable(name: "style-swift", targets: ["style-swift"]),
    .plugin(name: "FormatSwift", targets: ["FormatSwiftCommand"]),
    .plugin(name: "FormatSwiftBuildPlugin", targets: ["FormatSwiftBuildPlugin"]),
    .library(name: "Testing", targets: ["Testing"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.3")
  ],
  targets: [
    .target(
      name: "Testing",
      plugins: [
        .plugin(name: "FormatSwiftBuildPlugin")
      ]
    ),
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
        .target(name: "style-swift"),
        .target(name: "SwiftLintBinary"),
        .target(name: "swiftformat")
      ]
    ),
    .plugin(
      name: "FormatSwiftBuildPlugin",
      capability: .buildTool(),
      dependencies: [
        .target(name: "StyleSwift"),
        .target(name: "SwiftLintBinary"),
        .target(name: "swiftformat")
      ]
    ),
    .binaryTarget(
      name: "swiftformat",
      url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.51.2/swiftformat.artifactbundle.zip",
      checksum: "d8954ff40cf39d8e343eabd83e730bd8c85a27463e356e66cd51808ca3badcc7"
    ),
    .binaryTarget(
      name: "SwiftLintBinary",
      url: "https://github.com/realm/SwiftLint/releases/download/0.50.3/SwiftLintBinary-macos.artifactbundle.zip",
      checksum: "abe7c0bb505d26c232b565c3b1b4a01a8d1a38d86846e788c4d02f0b1042a904"
    ),
    .binaryTarget(
      name: "StyleSwift",
      path: "StyleSwift-macos.artifactbundle.zip"
    )
  ]
)
