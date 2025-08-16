// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ComputerController",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ComputerController", targets: ["ComputerController"])
    ],
    targets: [
        .executableTarget(
            name: "ComputerController"
        ),
    ]
)
