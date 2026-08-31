//
//  BoniChineseCalendarCellPlugin.swift
//  Calendr
//
//  Boni Chinese Edition - combines upstream lunar/solar with mainland holidays
//

import AppKit

struct BoniChineseCalendarCellPlugin: CalendarCellPlugin {
    let text: String?
    let textColor: NSColor?
    let font: NSFont?
    let spacing: CGFloat? = 1

    init(
        for date: Date,
        events: [EventModel],
        calendar: Calendar,
        showLunarCalendar: Bool,
        showMainlandHolidays: Bool,
        showSolarTerms: Bool
    ) {
        // Holiday has highest priority
        if showMainlandHolidays, let holidayName = chineseMainlandHolidayName(from: events, date: date, calendar: calendar) {
            text = holidayName
            let isRestDay = isChineseMainlandRestDay(from: events, date: date, calendar: calendar)
            textColor = isRestDay
                ? NSColor.systemRed.withAlphaComponent(0.8)
                : NSColor.systemRed.withAlphaComponent(0.65)
            font = .systemFont(ofSize: 9, weight: .semibold)
            return
        }

        // Then solar terms (if enabled and lunar is enabled)
        if showSolarTerms && showLunarCalendar, let solarTerm = ChineseSolarTerm(from: date) {
            text = solarTerm.text
            textColor = .systemBrown.withAlphaComponent(0.85)
            font = .systemFont(ofSize: 9, weight: .regular)
            return
        }

        // Finally lunar date
        if showLunarCalendar, let lunarDate = ChineseLunarDate(from: date) {
            text = lunarDate.text
            let isMonthStart = lunarDate.isMonthStart
            textColor = isMonthStart ? .labelColor : .secondaryLabelColor
            font = .systemFont(ofSize: 9, weight: isMonthStart ? .semibold : .regular)
            return
        }

        // No plugin text
        text = nil
        textColor = nil
        font = nil
    }

    static let cellSize: CGSize = .init(width: 30, height: 38)
}
