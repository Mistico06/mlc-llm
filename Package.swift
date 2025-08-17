// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MLCSwift",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MLCSwift",
            targets: ["MLCEngineObjC", "MLCSwift"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MLCEngineObjC",
            path: "ios/MLCSwift/Sources/ObjC",
            cxxSettings: [
                .define("TVM_ALWAYS_INLINE", to: "__attribute__((always_inline)) inline"),
                .headerSearchPath("../../../../3rdparty/tvm/include"),
                .headerSearchPath("../../../../3rdparty/tvm/ffi/include"),
                .headerSearchPath("../../../../3rdparty/tvm/3rdparty/dmlc-core/include"),
                .headerSearchPath("../../../../3rdparty/tvm/3rdparty/dlpack/include")
            ]
        ),
        .target(
            name: "MLCSwift",
            dependencies: ["MLCEngineObjC"],
            path: "ios/MLCSwift/Sources/Swift",
            // Exclude demo apps: MLCChat and MLCEngineExample
            exclude: [
                // Whole folders (preferred if they exist)
                "MLCChat",
                "MLCEngineExample",

                // Common demo entry-point files (in case they’re at top-level)
                "MLCChatApp.swift",
                "ContentView.swift"
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)
