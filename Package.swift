// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NovaxKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "NovaxMobileBridge", targets: ["NovaxMobileBridge"]),
        .library(name: "NovaxUI", targets: ["NovaxUI"]),
        .library(name: "NovaxSecurity", targets: ["NovaxSecurity"]),
        .library(name: "NovaxUtils", targets: ["NovaxUtils"]),
    ],
    targets: [
        .target(name: "NovaxMobileBridge", path: "Sources/NovaxMobileBridge"),
        .target(name: "NovaxUI", path: "Sources/NovaxUI"),
        .target(name: "NovaxSecurity", path: "Sources/NovaxSecurity"),
        .target(name: "NovaxUtils", path: "Sources/NovaxUtils"),
    ]
)
