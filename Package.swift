// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BloomChat",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "BloomChat",
            targets: ["BloomChat"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/zmeyc/telegram-bot-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/orlandos-nl/MongoKitten", from: "7.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BloomChat",
            dependencies: [
                .product(name: "TelegramBotSDK", package: "telegram-bot-swift"),
                .product(name: "MongoKitten", package: "MongoKitten"),
                .product(name: "Alamofire", package: "Alamofire")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "BloomChatTests",
            dependencies: ["BloomChat"]),
    ]
)
