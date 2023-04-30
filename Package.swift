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
      //exclude: ["package.json", "yarn.lock"],
      resources: [
        //.process("node_modules"),
        .copy("node_modules/prettier/standalone.js"),
        .copy("node_modules/prettier/parser-babel.js"),
      ]
    ),
    .testTarget(
      name: "PrettierFormattingTests",
      dependencies: ["PrettierFormatting"]
    ),
  ]
)
