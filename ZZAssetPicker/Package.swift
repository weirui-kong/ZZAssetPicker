// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZZAssetPicker",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "ZZAssetPicker",
            targets: ["ZZAssetPicker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "ZZAssetPicker",
            dependencies: ["SnapKit"],
            path: "Sources"
        ),
        .testTarget(
            name: "ZZAssetPickerTests",
            dependencies: ["ZZAssetPicker"],
            path: "Tests"
        ),
    ]
)
