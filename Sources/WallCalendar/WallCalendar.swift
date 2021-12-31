import Foundation
import OrderedCollections

typealias Day = [String: AnyHashable]

func monthIdentifier(from comps: DateComponents) -> String {
  guard let year = comps.year, let month = comps.month else {
    return ""
  }
  return [String(format: "%04d", year), String(format: "%02d", month)].joined()
}

func weekIdentifier(from comps: DateComponents) -> String {
  guard let year = comps.year, let weekOfYear = comps.weekOfYear else {
    return ""
  }
  return [String(format: "%04d", year), String(format: "%02d", weekOfYear)].joined()
}

func day(from comps: DateComponents) -> Day {
  return [
    "month_identifier": monthIdentifier(from: comps),
    "week_identifier": weekIdentifier(from: comps),
    "year": comps.year,
    "month": comps.month,
    "day": comps.day,
    "week_of_year": comps.weekOfYear,
    "weekday": comps.weekday,
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

func days(between from: Date, and to: Date, in calendar: Calendar) -> [Day] {
  let comps: DateComponents = calendar.dateComponents(
    [.day],
    from: from,
    to: to
  )
  guard let daysCount = comps.day else { return [] }
  return (0...daysCount)
    .compactMap { calendar.date(byAdding: .day, value: $0, to: from) }
    .map { calendar.dateComponents([.year, .month, .day, .weekOfYear, .weekday], from: $0) }
    .map { day(from: $0) }
}

func extendedDays(between startDate: Date, and endDate: Date, in calendar: Calendar) -> [Day] {
  let from = startOfWeek(for: startDate, in: calendar)
  let to = endOfWeek(for: endDate, in: calendar)
  return days(between: from, and: to, in: calendar)
}

func groupByWeek(_ days: [Day]) -> [[Day]] {
  OrderedDictionary(grouping: days) { $0["week_identifier"] as! String }.map(\.value)
}

func isAtLeastOne(of days: [Day], in month: String) -> Bool {
  days.map { $0["month_identifier"] as? String }.contains(month)
}

func groupByMonth(_ daysByWeek: [[Day]]) -> [[[Day]]] {
  var result = [[[Day]]]()

  let monthIdentifiers = Set(daysByWeek.flatMap { $0 }.map { $0["month_identifier"] as! String })
    .sorted()

  monthIdentifiers
    .map { monthIdentifier in
      daysByWeek.filter { daysInWeek in isAtLeastOne(of: daysInWeek, in: monthIdentifier) }
    }
    .forEach { result.append($0) }

  return result
}

public func build(forDaysBetween startDate: Date, and endDate: Date, inCalendar calendar: Calendar)
  -> [[[[String: AnyHashable]]]]
{
  groupByMonth(groupByWeek(extendedDays(between: startDate, and: endDate, in: calendar)))
}
