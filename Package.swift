// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EnGarde",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "EnGarde", targets: ["EnGarde"])
    ],
    targets: [
        .executableTarget(
            name: "EnGarde",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
