// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "WordwellAI",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "WordwellAICore", targets: ["WordwellAICore"]),
        .library(name: "WordwellAIFoundationModels", targets: ["WordwellAIFoundationModels"]),
        .executable(name: "wordwell-ai", targets: ["WordwellAICLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        // Pure Swift: contracts, models, validation, cache, fallback. No FoundationModels import.
        .target(name: "WordwellAICore", resources: [.process("Resources/restricted-terms.json")]),
        // Apple on-device model implementation (iOS 26+ / macOS 26+ at runtime).
        .target(
            name: "WordwellAIFoundationModels",
            dependencies: ["WordwellAICore"]
        ),
        // Developer CLI: run features, inspect prompts/tokens, run eval suites.
        .executableTarget(
            name: "WordwellAICLI",
            dependencies: [
                "WordwellAICore",
                "WordwellAIFoundationModels",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/wordwell-ai",
            resources: [.process("Resources")]
        ),
        .testTarget(name: "WordwellAICoreTests", dependencies: ["WordwellAICore"]),
        .testTarget(name: "WordwellAIFoundationModelsTests", dependencies: ["WordwellAIFoundationModels"]),
    ],
    swiftLanguageModes: [.v6]
)
