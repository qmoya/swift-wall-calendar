import Foundation
import OrderedCollections
import Capsule

typealias Map = HashMap<String, AnyHashable>
extension String: Error {}

func createDay(_ day: Int, week: Int, month: Int, year: Int, calendar: Calendar) throws -> Map {
	let comps: DateComponents = .init(calendar: calendar, year: year, month: month, day: day)
	guard let startOfDay = comps.date else {
		throw "unable to create date"
	}
	
	guard let year = comps.year, let month = comps.month, let day = comps.day else {
		throw "unable to get components"
	}

	return [
		"starts_at": startOfDay,
		"year": year,
		"month": month,
		"day": day,
		"week_of_year": week
	]
}

func createWeek(_ week: Int, year: Int, calendar: Calendar) throws -> Map {
	let comps: DateComponents = .init(calendar: calendar, year: year, weekday: calendar.firstWeekday, weekOfYear: week)
	guard let startOfWeek = comps.date else {
		throw "unable to compute start of week"
	}
		
	var days: [Map] = []
	var monthAndYears: OrderedSet<Map> = []
	
	for i in 0..<7 {
		guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else {
			throw "unable to compute date for the day"
		}
		
		let dateComponents = calendar.dateComponents([.month, .year], from: date)
		guard let month = dateComponents.month, let year = dateComponents.year else {
			throw "unable to compute month and year out of \(date)"
		}
		
		let monthAndYear: Map = [
			"month": month,
			"year": year
		]
		monthAndYears.append(monthAndYear)
		
		let day: Map = [
			"starts_at": date,
			"column": i,
			"week_of_year": week
		]
		
		days.append(day)
	}
	
	return [
		"starts_at": startOfWeek,
		"days": days,
		"month_and_years": monthAndYears
	]
}

func createWeeks(_ count: Int, startingOn startDate: Date, calendar: Calendar) throws -> [Map] {
	let dateComponents: DateComponents = calendar.dateComponents([.weekOfYear, .year], from: startDate)
	guard let week = dateComponents.weekOfYear, let year = dateComponents.year else {
		throw "unable to extract weekOfYear and year out of \(dateComponents)"
	}
	var weeks: [Map] = []
	for i in 0..<count {
		let week = try createWeek(week + i, year: year, calendar: calendar)
		weeks.append(week)
	}
	printWeeks(weeks)
	return weeks
}

func printWeek(_ week: Map) {
	guard let days = week["days"] as? [Map] else {
		return
	}
	let result = days.compactMap { $0["day"] as? Int }
	print(result)
}

func printWeeks(_ weeks: [Map], using printer: (Map) -> Void = printWeek) {
	weeks.forEach(printer)
}
