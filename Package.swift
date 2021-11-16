// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "javascript-formatting",
  platforms: [
    .macOS(.v10_10),
    .iOS(.v8),
    .tvOS(.v9),
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
      exclude: ["Documentation.docc", "package.json", "yarn.lock"],
      resources: [.copy("node_modules")]
    ),
    .testTarget(
      name: "JavaScriptFormattingTests",
      dependencies: ["JavaScriptFormatting"]
    ),
  ]
)
