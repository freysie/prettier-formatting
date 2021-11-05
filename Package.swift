// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "javascript-formatting",
  platforms: [
    .macOS(.v12),
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "JavaScriptFormatting",
      targets: ["JavaScriptFormatting"]
    ),
  ],
  targets: [
    .target(
      name: "JavaScriptFormatting",
      exclude: ["package.json", "yarn.lock"],
      resources: [.copy("node_modules")]
    ),
    .testTarget(
      name: "JavaScriptFormattingTests",
      dependencies: ["JavaScriptFormatting"]
    ),
  ]
)
