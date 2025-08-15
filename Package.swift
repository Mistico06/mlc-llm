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
            targets: ["MLCSwift"]
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
            /* Same name as the product so `import MLCSwift` works */
            name: "MLCSwift",

            /* Path to the Sources directory that already contains ObjC + Swift */
            path: "ios/MLCSwift/Sources",

            /* Public headers for Objective-C clients (already present) */
            publicHeadersPath: "ObjC/include",

            /* C / C++ compiler flags that MLCSwift expects */
            cSettings: [
                .define("TVM_USE_LIBBACKTRACE", to: "0"),
                .define("DMLC_USE_LOGGING_LIBRARY", to: "1")
            ],
            cxxSettings: [
                .unsafeFlags(["-std=c++17"])
            ],

            /* Link the pre-built static libs shipped in ios/MLCSwift/lib */
            linkerSettings: [
                .unsafeFlags([
                    "-L\(Package.rootPath)/ios/MLCSwift/lib",  // search path
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
        )
    ]
)

/* ------------------------------------------------------------------ */
/* Helper to make the -L path robust even when SPM puts the checkout  */
/* in a long hash path inside DerivedData.                            */
#if swift(>=5.7)
extension Package {
    static var rootPath: String { #filePath.split(separator: "/").dropLast().joined(separator: "/") }
}
#endif
