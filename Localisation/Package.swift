// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Localisation",
    platforms: [.iOS(.v17)],
    products: [

        .library(
            name: "Localisation",
            targets: ["Localisation"]
        ),
    ],
    targets: [
        .target(
            name: "Localisation",
            dependencies: [],
            resources: [
                .process("Assets")
            ]
        ),

    ]
)
