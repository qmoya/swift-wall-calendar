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
		let day = day(from: .init(year: 2021, month: 12, day: 1))
		
		assertSnapshot(matching: day, as: .dump)
	}
		
	func testItCreatesAWeek() throws {
		let week: [[Map]] = daysGroupedByWeek(days(between: date("2021-12-27"), and: date("2022-01-02"), in: calendar))
			
		let dates = week.flatMap { $0.map { $0["day"] } }
				
		XCTAssertEqual(dates, [27, 28, 29, 30, 31, 1, 2])
	}
	
	func testItCreatesMonths() {
		let months = months(daysByWeek: daysGroupedByWeek(days(between: date("2021-12-21"), and: date("2022-02-02"), in: calendar)))
		
		assertSnapshot(matching: months, as: .dump)
	}
	
	func testDaysForSameDay() {
		// given
		let start = date("2021-12-21")
		let end = start

		// when
		let days = days(between: start, and: end, in: calendar)
		
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
	
	func testBuildingCalendar() {
		let result = build(forDaysBetween: date("2021-12-30"), and: date("2022-12-30"), inCalendar: calendar)
		assertSnapshot(matching: result, as: .dump)
	}
}
