// swift-tools-version:5.7
import PackageDescription

let package = Package(
    /* The name by which other projects will reference this package */
    name: "mlc-llm",
    /* Supported platforms (match those used inside ios/MLCSwift) */
    platforms: [
        .iOS(.v15)
    ],
    /* What this package exports to clients */
    products: [
        .library(
            name: "MLCSwift",
            targets: ["MLCEngineObjC", "MLCSwift"]
        )
    ],
    /* External dependencies for MLCSwift itself (none today) */
    dependencies: [
        // When MLCSwift starts depending on external SPM packages,
        // list them here.
    ],
    /* Tie the root package to the real sources in ios/MLCSwift */
    targets: [
        .target(
            /* MLCEngineObjC target, ObjC++ sources */
            name: "MLCEngineObjC",
            path: "ios/MLCSwift/Sources/ObjC",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("../../tvm_home/include"),
                .headerSearchPath("../../tvm_home/ffi/include"),
                .headerSearchPath("../../tvm_home/3rdparty/dmlc-core/include"),
                .headerSearchPath("../../tvm_home/3rdparty/dlpack/include"),
                .unsafeFlags(["-std=c++17"])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-L\(Package.rootPath)/ios/MLCSwift/lib",
                    "-Wl,-all_load",
                    "-lmodel_iphone",
                    "-lmlc_llm",
                    "-ltvm_runtime",
                    "-ltokenizers_cpp",
                    "-lsentencepiece",
                    "-ltokenizers_c",
                    "-Wl,-noall_load"
                ])
            ]
        ),
        .target(
            /* MLCSwift target, depends on MLCEngineObjC, Swift sources */
            name: "MLCSwift",
            dependencies: ["MLCEngineObjC"],
            path: "ios/MLCSwift/Sources/Swift"
        )
    ]
)

#if swift(>=5.7)
extension Package {
    static var rootPath: String { #filePath.split(separator: "/").dropLast().joined(separator: "/") }
}
#endif
