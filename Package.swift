// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftStyleGuide",
  products: [
    .library(
      name: "SwiftStyleGuideTool",
      targets: ["SwiftStyleGuideTool"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "SwiftStyleGuideTool",
      dependencies: []
    ),
    .testTarget(
      name: "SwiftStyleGuideToolTests",
      dependencies: ["SwiftStyleGuideTool"]
    ),
  ]
)
