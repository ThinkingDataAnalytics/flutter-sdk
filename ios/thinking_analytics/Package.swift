// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "thinking_analytics",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "thinking-analytics", targets: ["thinking_analytics"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Same remote source as TestIosDemo: ThinkingData iOS SDK 3.4.8
        .package(
            url: "https://github.com/ThinkingDataAnalytics/ios-sdk",
            exact: "3.4.8"
        )
    ],
    targets: [
        .target(
            name: "thinking_analytics",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "ThinkingSDK", package: "ios-sdk")
            ],
            cSettings: [
                .headerSearchPath("include/thinking_analytics")
            ]
        )
    ]
)
