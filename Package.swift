// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "mlc-llm",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MLCSwift",
            targets: ["MLCSwift"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MLCSwift",
            path: "ios/MLCSwift/Sources"
        )
    ]
)
