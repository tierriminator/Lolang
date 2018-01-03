// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "lolc",
    dependencies: [
        .package(url: "https://github.com/trill-lang/LLVMSwift", .branch("master")),
        .package(url: "https://github.com/kylef/PathKit", .branch("master")),
        .package(url: "https://github.com/oarrabi/FileUtils", .branch("master")),
        .package(url: "https://github.com/tierriminator/GlibcVersion", .branch("master"))
    ],
    targets: [
        .target(name: "Lib", dependencies: ["LLVM", "PathKit", "FileUtils"]),
        .target(name: "lolc", dependencies: ["Lib"]),
        .testTarget(name: "LibTests", dependencies: ["Lib"])
    ]
)
