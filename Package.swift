// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "swift-wall-calendar",
    products: [
        .library(
            name: "WallCalendar",
            targets: ["WallCalendar"]),
    ],
    dependencies: [
		.package(
		  url: "https://github.com/apple/swift-collections.git",
		  .upToNextMajor(from: "1.0.0") // or `.upToNextMinor
		),
		
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "WallCalendar",
            dependencies: [
				.product(name: "OrderedCollections", package: "swift-collections")
			]),
        .testTarget(
            name: "WallCalendarTests",
            dependencies: [
				"WallCalendar",
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
			]),
    ]
)
