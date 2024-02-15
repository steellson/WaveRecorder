// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WRParts",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "WRParts",
            targets: ["WRParts"]),
    ],
    dependencies: [
        .package(path: "../Foundation"),
        .package(path: "../UIKit")
    ],
    targets: [
        .target(
            name: "WRParts")
    ]
)
