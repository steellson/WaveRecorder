// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WRResources",
    products: [
        .library(
            name: "WRResources",
            targets: ["WRResources"]),
    ],
    targets: [
        .target(
            name: "WRResources")
    ]
)
