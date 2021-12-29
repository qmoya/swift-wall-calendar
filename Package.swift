// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WallCalendars",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "WallCalendars",
            targets: ["WallCalendars"]),
    ],
    dependencies: [
		.package(url: "https://github.com/msteindorfer/swift-collections.git", .branch("capsule-collections"))
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "WallCalendars",
            dependencies: [
				.product(name: "Capsule", package: "swift-collections"),
				.product(name: "OrderedCollections", package: "swift-collections")
			]),
        .testTarget(
            name: "WallCalendarsTests",
            dependencies: ["WallCalendars"]),
    ]
)
