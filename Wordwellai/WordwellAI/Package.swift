// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "WordwellAI",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "WordwellAICore", targets: ["WordwellAICore"]),
        .library(name: "WordwellAIFoundationModels", targets: ["WordwellAIFoundationModels"]),
        .library(name: "WordwellAIStorage", targets: ["WordwellAIStorage"]),
        .executable(name: "wordwell-ai", targets: ["WordwellAICLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        // Pure Swift: contracts, models, validation, cache, fallback. No FoundationModels import.
        .target(name: "WordwellAICore"),
        // Apple on-device model implementation (iOS 26+ / macOS 26+ at runtime).
        .target(
            name: "WordwellAIFoundationModels",
            dependencies: ["WordwellAICore"]
        ),
        // App adapters: SQLite FTS5 dictionary (AIDictionaryLookup + DefinitionSearching)
        // and SwiftData mistakes notebook (MistakeNotebook).
        .target(
            name: "WordwellAIStorage",
            dependencies: ["WordwellAICore"]
        ),
        // Developer CLI: run features, inspect prompts/tokens, run eval suites.
        .executableTarget(
            name: "WordwellAICLI",
            dependencies: [
                "WordwellAICore",
                "WordwellAIFoundationModels",
                "WordwellAIStorage",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/wordwell-ai",
            resources: [.process("Resources")]
        ),
        .testTarget(name: "WordwellAICoreTests", dependencies: ["WordwellAICore"]),
        .testTarget(name: "WordwellAIStorageTests", dependencies: ["WordwellAIStorage", "WordwellAICore"]),
    ],
    swiftLanguageModes: [.v6]
)
