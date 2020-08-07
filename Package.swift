// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KeychainKit",
  platforms: [.iOS(.v8)],
  products: [
    .library(name: "KeychainKit", targets: ["KeychainKit"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "KeychainKit", dependencies: [])
  ]
)
