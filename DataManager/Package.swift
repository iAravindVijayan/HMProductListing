// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataManager",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "NetworkEngine",
            targets: ["NetworkEngine"]
        ),
        .library(
            name: "CacheManager",
            targets: ["CacheManager"]
        ),
    ],
    targets: [
        .target(
            name: "NetworkEngine",
            dependencies: [],
            path: "Sources/NetworkEngine"
        ),
        .target(
            name: "CacheManager",
            dependencies: [
                "NetworkEngine"
            ],
            path: "Sources/CacheManager"
        ),
    ]
)
