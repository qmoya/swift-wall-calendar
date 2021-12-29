import Foundation
import OrderedCollections

typealias Day = ValueDictionary
typealias Week = ValueDictionary
typealias Month = ValueDictionary
typealias MonthAndYear = ValueDictionary
extension String: Error {}

func createDay(_ day: Int, week: Int, month: Int, year: Int, calendar: Calendar) throws -> Day {
	let dateComponents: DateComponents = .init(calendar: calendar, year: year, month: month, day: day)
	guard let startOfDay: Date = dateComponents.date else {
		throw "unable to create date"
	}

	return [
		"starts_at": .date(startOfDay),
		"week_number": .integer(week)
	]
}

func createWeek(_ week: Int, year: Int, calendar: Calendar) throws -> Week {
	let dateComponents: DateComponents = .init(calendar: calendar, year: year, weekday: calendar.firstWeekday, weekOfYear: week)
	guard let startOfWeek: Date = dateComponents.date else {
		throw "unable to compute start of week"
	}
		
	var days: [Value] = []
	var monthAndYears: OrderedSet<MonthAndYear> = []
	
	for i in 0..<7 {
		guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else {
			throw "unable to compute date for the day"
		}
		
		let dateComponents = calendar.dateComponents([.month, .year], from: date)
		guard let month = dateComponents.month, let year = dateComponents.year else {
			throw "unable to compute month and year out of \(date)"
		}
		
		let monthAndYear: MonthAndYear = [
			"month": .integer(month),
			"year": .integer(year)
		]
		monthAndYears.append(monthAndYear)
		
		let day: Day = [
			"starts_at": .date(date),
			"column": .integer(i),
			"week_of_year": .integer(week)
		]
		
		days.append(.dictionary(day))
	}
	
	return [
		"starts_at": .date(startOfWeek),
		"days": .array(days),
		"month_and_years": .array(monthAndYears.map { .dictionary($0) })
	]
}

func createMonth(_ month: Int, year: Int, calendar: Calendar) throws -> Month {
	let dateComponents: DateComponents = .init(calendar: calendar, year: year, month: month)
	guard let beginningOfMonth: Date = dateComponents.date else {
		throw "unable to create date"
	}
	
	return [
		"id": .date(beginningOfMonth)
	]
}

func createWeeks(_ count: Int, startingOn startDate: Date, calendar: Calendar) throws -> [Week] {
	let dateComponents: DateComponents = calendar.dateComponents([.weekOfYear, .year], from: startDate)
	guard let week = dateComponents.weekOfYear, let year = dateComponents.year else {
		throw "unable to extract weekOfYear and year out of \(dateComponents)"
	}
	var weeks: [Week] = []
	for i in 0..<count {
		let week = try createWeek(week + i, year: year, calendar: calendar)
		weeks.append(week)
	}
	printWeeks(weeks)
	return weeks
}

func printWeek(_ week: Week) {
	var result: [Int] = []
	
	switch week["days"] {
	case let .array(days):
		for day in days {
			switch day {
			case let .integer(i):
				result.append(i)
			default:
				continue
			}
		}
	default:
		break
	}
}

func printWeeks(_ weeks: [Week], using printer: (Week) -> Void = printWeek) {
	weeks.forEach(printer)
}
