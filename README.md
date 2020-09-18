# corvus-notifications

This package adds functionality for push notifications to [Corvus](https://github.com/Apodini/corvus), a declarative server-side framework for Swift.

# Example

Below is an example of an API that manages Bank Accounts belonging to certain users. You can use the .notify() modifier on any Create, Read, Update oder Delete endpoint.

```Swift
final class AccountsEndpoint: Endpoint {
    let parameter = Parameter<Account>()
    
    var content: Endpoint {
        Group("accounts") {
            Create<Account>().notify()
            
            Group(parameter.id) {
                ReadOne<Account>(parameter.id).auth(\.$user)
                Update<Account>(parameter.id).auth(\.$user).notify()
            }
        }
    }
}
```

# Set Up

After creating your Swift Project you will need to add the dependencies for [Corvus](https://github.com/Apodini/corvus) and add a dependency for `corvus-notifications`. Below is an example using SQLite:

```Swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "XpenseServer",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "XpenseServer", targets: ["XpenseServer"])
    ],
    dependencies: [
         .package(url: "https://github.com/Apodini/corvus-notifications.git", from: "0.0.1"),
        .package(url: "https://github.com/Apodini/corvus.git", from: "0.0.16"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0")
    ],
    targets: [
        .target(name: "Run",
                dependencies: [
                    .target(name: "XpenseServer")
                ]),
        .target(name: "XpenseServer",
                dependencies: [
                    .product(name: "Corvus", package: "corvus"),
                    .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
                ]),
        .testTarget(name: "XpenseServerTests",
                    dependencies: [
                        .target(name: "XpenseServer"),
                        .product(name: "XCTVapor", package: "vapor"),
                        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
                    ])
    ]
)
```

# How to contribute
Contributions to this projects are welcome. Please make sure to read the [contribution guidelines](https://github.com/Apodini/.github/blob/release/CONTRIBUTING.md) first.

# Sources

[Corvus](https://github.com/Apodini/corvus)

[Vapor](https://github.com/vapor/vapor)

[Fluent](https://github.com/vapor/fluent)