// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NectoFlagToggle",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
    ],
    products: [
        .library(name: "NectoFlagTogglePlugin", targets: ["NectoFlagTogglePlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/toss/necto.git", exact: "0.2.0"),
    ],
    targets: [
        .target(
            name: "NectoFlagTogglePlugin",
            dependencies: [
                .product(name: "NectoSDK", package: "necto"),
            ],
            resources: [
                .copy("Panel"),
            ]
        ),
        .testTarget(
            name: "NectoFlagTogglePluginTests",
            dependencies: ["NectoFlagTogglePlugin"]
        ),
    ]
)
