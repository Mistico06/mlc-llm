// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MLCSwift",
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
            publicHeadersPath: "include",
            cSettings: [
                .define("DMLC_USE_LOGGING_LIBRARY", to: "1"),
                .define("TVM_USE_LIBBACKTRACE", to: "0")
            ],
            cxxSettings: [
                .define("TVM_ALWAYS_INLINE", to: "__attribute__((always_inline)) inline"),
                .headerSearchPath("../../../../3rdparty/tvm/include"),
                .headerSearchPath("../../../../3rdparty/tvm/ffi/include"),
                .headerSearchPath("../../../../3rdparty/tvm/3rdparty/dmlc-core/include"),
                .headerSearchPath("../../../../3rdparty/tvm/3rdparty/dlpack/include"),
                .unsafeFlags(["-std=c++17"])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-L" + Package.rootPath + "/ios/MLCSwift/lib",
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
