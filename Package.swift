// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TokenTextView",
    products: [
        .library(
            name: "TokenTextView",
            targets: ["TokenTextView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TokenTextView",
            dependencies: []),
        .testTarget(
            name: "TokenTextViewTests",
            dependencies: ["TokenTextView"],
            resources: [
                .copy("Mocks/MockTokens.json"),
                .copy("Mocks/MockTokenInstances.json"),
                .copy("Mocks/MockTemplateText.txt"),
                .copy("Mocks/MockPlainText.txt")
            ]),
    ],
    swiftLanguageVersions: [.v5]

)
