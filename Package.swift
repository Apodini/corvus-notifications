// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "corvus-notifications",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "corvus-notifications",
            targets: ["corvus-notifications"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/Apodini/corvus.git", from: "0.0.16"),
        .package(name: "apnswift", url: "https://github.com/kylebrowning/APNSwift.git", from: "2.0.0-rc1")
    ],
    targets: [
        .target(
            name: "corvus-notifications",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Corvus", package: "corvus"),
                .product(name: "APNSwift", package: "apnswift")]),
        .testTarget(
            name: "CorvusNotificationsTests",
            dependencies: [.target(name: "corvus-notifications"), .product(name: "XCTVapor", package: "vapor")])
    ]
)
