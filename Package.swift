// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "prettier-formatting",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
  ],
  products: [
    .library(
      name: "PrettierFormatting",
      targets: ["PrettierFormatting"]
    )
  ],
  targets: [
    .target(
      name: "PrettierFormatting",
      //exclude: ["package.json", "yarn.lock"],
      resources: [
        //.process("node_modules"),
        .copy("node_modules/prettier/standalone.js"),
        .copy("node_modules/prettier/plugins/babel.js"),
        .copy("node_modules/prettier/plugins/estree.js"),
        .copy("sql-plugin-standalone.js"),
      ]
    ),
    .testTarget(
      name: "PrettierFormattingTests",
      dependencies: ["PrettierFormatting"]
    ),
  ]
)
