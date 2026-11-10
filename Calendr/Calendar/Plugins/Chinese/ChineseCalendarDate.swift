import Foundation

// Lunar dates and solar terms use the Chinese civil date displayed in the grid.
// Translate date components, rather than shifting a local midnight into another day.
func chineseCalendarDate(for date: Date, calendar: Calendar) -> Date? {
    var gregorian = Calendar(identifier: .gregorian)
    gregorian.timeZone = calendar.timeZone
    var components = gregorian.dateComponents([.year, .month, .day], from: date)
    components.hour = 12
    gregorian.timeZone = .shanghai
    return gregorian.date(from: components)
}
