import XCTest
@testable import WallCalendars
import Foundation
import SnapshotTesting

final class WallCalendarsTests: XCTestCase {
	var dateFormatter: DateFormatter!
	var calendar: Calendar!
		
	override func setUpWithError() throws {
		dateFormatter = DateFormatter()
		dateFormatter.timeZone = .init(secondsFromGMT: 0)
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		calendar = .init(identifier: .gregorian)
		calendar.timeZone = .init(secondsFromGMT: 0)!
		calendar.firstWeekday = 2
	}
	
	func date(_ yyyyMMMDD: String) -> Date {
		dateFormatter.date(from: yyyyMMMDD)!
	}
	
    func testItCreatesDays() throws {
		let day = try createDay(1, week: 1, month: 12, year: 2021, calendar: calendar)
		let expectedDate = dateFormatter.date(from: "2021-12-01")!
		
		XCTAssertEqual(day["starts_at"], expectedDate)
		XCTAssertEqual(day["week_of_year"], 1)
	}
		
	func testItCreateAWeek() throws {
		let week: Map = try createWeek(1, year: 2022, calendar: calendar)
			
		let dates: [Date]? = (week["days"] as? [Map])?
			.compactMap { $0 }
			.compactMap { $0["starts_at"] as? Date }
				
		XCTAssertEqual(dates, [
			dateFormatter.date(from: "2021-12-27")!,
			dateFormatter.date(from: "2021-12-28")!,
			dateFormatter.date(from: "2021-12-29")!,
			dateFormatter.date(from: "2021-12-30")!,
			dateFormatter.date(from: "2021-12-31")!,
			dateFormatter.date(from: "2022-01-01")!,
			dateFormatter.date(from: "2022-01-02")!
		])
	}
	
//	func testAWeekBelongsToTwoMonths() throws {
//		let week = try createWeek(1, year: 2022, calendar: calendar)
//
//		switch week["month_and_years"] {
//		case let .array(months):
//			XCTAssertEqual(months, [
//				.dictionary([
//					"year": .integer(2021),
//					"month": .integer(12)
//				]),
//				.dictionary([
//					"year": .integer(2022),
//					"month": .integer(1)
//				])
//			])
//		default:
//			XCTFail()
//		}
//	}
//
//	func testItCreatesWeeks() throws {
//		let weeks = try createWeeks(10, startingOn: .distantPast, calendar: calendar)
//
//		XCTAssertEqual(weeks.count, 10)
//	}
	
	func testItWalksTheCalendar() {
		let uuid = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
		let months = months(daysByWeek: daysGroupedByWeek(days(between: date("2021-12-21"), and: date("2022-02-02"), in: calendar, buildUUID: { uuid })))
		
		assertSnapshot(matching: months, as: .dump)
	}
	
	func testDaysForSameDay() {
		// given
		let start = date("2021-12-21")
		let end = start
		
		let uuid = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
		
		// when
		let days = days(between: start, and: end, in: calendar, buildUUID: { uuid })
		
		// then
		assertSnapshot(matching: days, as: .dump)
	}
	
	func testBeginningOfWeek() {
		let start = startOfWeek(for: date("2021-12-29"), in: calendar)
		XCTAssertEqual(start, date("2021-12-27"))
	}
	
	func testEndOfWeek() {
		let end = endOfWeek(for: date("2021-12-29"), in: calendar)
		XCTAssertEqual(end, date("2022-01-02"))
	}
}
