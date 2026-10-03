// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WordwellKit",
    platforms: [.iOS("27.0"), .macOS(.v15)],
    products: [
        .library(name: "WordwellDomain", targets: ["WordwellDomain"]),
        .library(name: "WordwellDesign", targets: ["WordwellDesign"]),
        .library(name: "WordwellData", targets: ["WordwellData"]),
        .library(name: "WordwellAI", targets: ["WordwellAI"]),
    ],
    targets: [
        .target(name: "WordwellDomain"),
        .target(
            name: "WordwellDesign",
            resources: [.copy("Resources/Fonts"), .process("Resources/IllustrationsSVG/Words.xcassets"), .process("Resources/IllustrationsSVG/PhrasalVerbs.xcassets")]
        ),
        .target(
            name: "WordwellData",
            dependencies: ["WordwellDomain"],
            resources: [
                .copy("Resources/Dictionary.sqlite"),
                .copy("Resources/ATTRIBUTION.txt"),
                .copy("Resources/Grammar.json"),
                .copy("Resources/OEWN_LICENSE.md"),
                .copy("Resources/WNDB_License.txt"),
                .copy("Resources/IllustrationsSVG"),
            ]
        ),
        .target(name: "WordwellAI", dependencies: ["WordwellDomain"]),
        .testTarget(
            name: "WordwellArchitectureTests",
            dependencies: ["WordwellDomain", "WordwellDesign", "WordwellData", "WordwellAI"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
