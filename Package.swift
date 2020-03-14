// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FaceppSwift",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v9), .watchOS(.v3)
    ],
    products: [
        .executable(
            name: "facepp-cli",
            targets: ["FaceppCLI"]),
        .library(
            name: "FaceppSwift",
            targets: ["FaceppSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.1"),
        .package(url: "https://github.com/weichsel/ZIPFoundation/", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .target(
            name: "FaceppCLI",
            dependencies: ["FaceppSwift", "ArgumentParser", "ZIPFoundation"]),
        .target(
            name: "FaceppSwift",
            dependencies: []),
        .testTarget(
            name: "FaceppSwiftTests",
            dependencies: ["FaceppSwift"]),
        .testTarget(
            name: "FaceppCLITests",
            dependencies: ["FaceppCLI"]),
    ],
    swiftLanguageVersions: [.v5]
)
