// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "prettier-formatting",
  platforms: [
    .macOS(.v10_10),
    .iOS(.v9),
    .tvOS(.v9),
  ],
  products: [
    .library(
      name: "PrettierFormatting",
      targets: ["PrettierFormatting"]
    ),
  ],
  targets: [
    .target(
      name: "PrettierFormatting",
      exclude: ["package.json", "yarn.lock"],
      resources: [.copy("node_modules")]
    ),
    .testTarget(
      name: "PrettierFormattingTests",
      dependencies: ["PrettierFormatting"]
    ),
  ]
)
