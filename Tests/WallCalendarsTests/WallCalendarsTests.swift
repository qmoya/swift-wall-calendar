import XCTest
@testable import WallCalendars
import Foundation

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
	
    func testItCreatesDays() throws {
		let day = try createDay(1, week: 1, month: 12, year: 2021, calendar: calendar)
		let expectedDate = dateFormatter.date(from: "2021-12-01")!
		
		XCTAssertEqual(day["starts_at"], .date(expectedDate))
		XCTAssertEqual(day["week_number"], .integer(1))
	}
	
	func testItCreatesMonths() throws {
		let month = try createMonth(12, year: 2021, calendar: calendar)
		
		
		let expectedDate = dateFormatter.date(from: "2021-12-01")!
		XCTAssertEqual(month["id"], .date(expectedDate))
	}
	
	func testItCreateAWeek() throws {
		let week = try createWeek(1, year: 2022, calendar: calendar)
	
		switch week["days"] {
		case let .array(days):
			let days: [Day] = days.compactMap {
				switch $0 {
				case let .dictionary(day):
					return day
				default:
					return nil
				}
			}
			
			let dates: [Date] = days.compactMap { day in
				switch day["starts_at"] {
				case let .some(.date(date)):
					return date
				default:
					return nil
				}
			}
			
			XCTAssertEqual(dates, [
				dateFormatter.date(from: "2021-12-27")!,
				dateFormatter.date(from: "2021-12-28")!,
				dateFormatter.date(from: "2021-12-29")!,
				dateFormatter.date(from: "2021-12-30")!,
				dateFormatter.date(from: "2021-12-31")!,
				dateFormatter.date(from: "2022-01-01")!,
				dateFormatter.date(from: "2022-01-02")!
			])

		default:
			XCTFail("unexpected value")
		}
	}
	
	func testAWeekBelongsToTwoMonths() throws {
		let week = try createWeek(1, year: 2022, calendar: calendar)

		switch week["month_and_years"] {
		case let .array(months):
			XCTAssertEqual(months, [
				.dictionary([
					"year": .integer(2021),
					"month": .integer(12)
				]),
				.dictionary([
					"year": .integer(2022),
					"month": .integer(1)
				])
			])
		default:
			XCTFail()
		}
	}
	
	func testItCreatesWeeks() throws {
		let weeks = try createWeeks(10, startingOn: .distantPast, calendar: calendar)
		
		XCTAssertEqual(weeks.count, 10)
	}
}
