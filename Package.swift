
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "greenBag",
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "10.45.2"))
    ]
)
