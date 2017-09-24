// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "LLC",
    dependencies: [
        .package(url: "https://github.com/trill-lang/LLVMSwift", .branch("master"))
    ],
    targets: [
        .target(name: "Lib", dependencies: ["LLVM"]),
        .target(name: "LLC", dependencies: ["Lib"]),
        .testTarget(name: "LibTests", dependencies: ["Lib"])
    ]
)
