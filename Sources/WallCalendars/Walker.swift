import Foundation
import OrderedCollections

func day(from comps: DateComponents, buildUUID: () -> UUID) -> Map {
	return [
		"id": buildUUID(),
		"year": comps.year,
		"month": comps.month,
		"day": comps.day,
		"week_of_year": comps.weekOfYear,
		"weekday": comps.weekday
	]
}

func startOfWeek(for date: Date, in calendar: Calendar) -> Date {
	var comps = calendar.dateComponents([.calendar, .weekOfYear, .yearForWeekOfYear], from: date)
	comps.weekday = calendar.firstWeekday
	return comps.date!
}

func endOfWeek(for date: Date, in calendar: Calendar) -> Date {
	let start = startOfWeek(for: date, in: calendar)
	return calendar.date(byAdding: .day, value: 6, to: start)!
}

func days(between startDate: Date, and endDate: Date, in calendar: Calendar, buildUUID: () -> UUID) -> [Map] {
	let from = startOfWeek(for: startDate, in: calendar)
	let to = endOfWeek(for: endDate, in: calendar)
	let comps: DateComponents = calendar.dateComponents(
		[.day],
		from: from,
		to: to
	)
	guard let daysCount = comps.day else { return [] }
	return (0...daysCount)
		.compactMap { calendar.date(byAdding: .day, value: $0, to: from) }
		.map { calendar.dateComponents([.year, .month, .day, .weekOfYear, .weekday], from: $0) }
		.map { day(from: $0, buildUUID: buildUUID) }
}

func daysGroupedByWeek(_ days: [Map]) -> [[Map]] {
	OrderedDictionary(grouping: days) { $0["week_of_year"] as? Int }.map(\.value)
}

func atLeast(oneOf days: [Map], isInMonth month: Int) -> Bool {
	days.map { $0["month"] as? Int }.contains(month)
}

func months(daysByWeek: [[Map]]) -> [[[Map]]] {
	var result = [[[Map]]]()
	(1...12)
		.map { month in
			daysByWeek.filter { daysInWeek in atLeast(oneOf: daysInWeek, isInMonth: month) }
		}
		.forEach { result.append($0) }
	
	return result
}
