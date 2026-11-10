//
//  ChineseHoliday.swift
//  Calendr
//

import Foundation

private let statutoryHolidayKeys = ["元旦", "春节", "除夕", "清明", "劳动", "端午", "中秋", "国庆"]
private let festivalHolidayKeys = ["元宵", "七夕", "重阳", "腊八"]
private let solarTermNames = [
    "小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨",
    "立夏", "小满", "芒种", "夏至", "小暑", "大暑",
    "立秋", "处暑", "白露", "秋分", "寒露", "霜降",
    "立冬", "小雪", "大雪", "冬至"
]

// Published schedules let the grid display holidays before system subscriptions sync.
// 2026: 国办发明电〔2025〕7号, published 2025-11-04.
// https://www.beijing.gov.cn/fwcj/calendar/shts/690abd58091e1a7398401381.html
// 2027: 国办发明电〔2026〕10号, published 2026-11-05.
// https://www.news.cn/politics/20261105/f90cd6ad4df94ab4833b141e52ccfc13/c.html
// Only add announced years; other years continue to use subscribed events.
private let mainlandRestPeriods: [Int: [(month: Int, days: ClosedRange<Int>, name: String)]] = [
    2026: [
        (1, 1...3, "元旦"),
        (2, 15...23, "春节"),
        (4, 4...6, "清明"),
        (5, 1...5, "劳动"),
        (6, 19...21, "端午"),
        (9, 25...27, "中秋"),
        (10, 1...7, "国庆")
    ],
    2027: [
        (1, 1...3, "元旦"),
        (2, 5...13, "春节"),
        (4, 3...5, "清明"),
        (5, 1...5, "劳动"),
        (6, 9...9, "端午"),
        (9, 15...15, "中秋"),
        (10, 1...7, "国庆")
    ]
]

func isChineseMainlandHolidayCalendar(_ calendar: CalendarModel) -> Bool {
    let haystack = normalizedHolidayTitle(calendar.title + " " + calendar.account.title)
    if haystack.contains("中国大陆节假日") { return true }
    if haystack.contains("中国节假日") { return true }
    if haystack.localizedCaseInsensitiveContains("Holidays in China") { return true }
    if haystack.localizedCaseInsensitiveContains("China Holidays") { return true }
    if haystack.contains("节假日") && (haystack.contains("中国") || haystack.contains("大陆")) {
        return true
    }
    return false
}

func isMainlandMakeupWorkTitle(_ title: String) -> Bool {
    let text = normalizedHolidayTitle(title).lowercased()
    if text.contains("non-working day") || text.contains("non working day") { return false }
    if text.contains("上班") || text.contains("补班") || text.contains("工作日") {
        return true
    }
    if text.contains("working day") || text.contains("workday") || text.contains("work day") {
        return true
    }
    return false
}

func isSolarTermName(_ title: String) -> Bool {
    let text = normalizedHolidayTitle(title).filter { !$0.isWhitespace }
    return solarTermNames.contains {
        text == $0 || text == $0 + "节气" || text == $0 + "（节气）" || text == $0 + "(节气)"
    }
}

func shortMainlandHolidayName(from title: String) -> String? {
    let title = normalizedHolidayTitle(title)
    if isMainlandMakeupWorkTitle(title) { return nil }
    if isSolarTermName(title) { return nil }

    for key in statutoryHolidayKeys + festivalHolidayKeys {
        if title.contains(key) {
            return key
        }
    }

    let english = title.lowercased().replacingOccurrences(of: "’", with: "'")
    let aliases = [
        ("除夕", ["chinese new year's eve", "lunar new year's eve"]),
        ("春节", ["chinese new year", "lunar new year", "spring festival"]),
        ("元旦", ["new year's day"]),
        ("清明", ["qingming", "tomb sweeping", "tomb-sweeping"]),
        ("劳动", ["labour day", "labor day"]),
        ("端午", ["dragon boat"]),
        ("中秋", ["mid-autumn", "mid autumn"]),
        ("国庆", ["national day"]),
        ("元宵", ["lantern festival"])
    ]
    if let alias = aliases.first(where: { $0.1.contains(where: english.contains) }) {
        return alias.0
    }

    if isExplicitMainlandRestTitle(title) {
        return "休息"
    }

    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    if trimmed.count <= 3 { return trimmed }
    return String(trimmed.prefix(2))
}

func chineseMainlandHolidayName(from events: [EventModel], date: Date, calendar: Calendar, schedules: [Int: MainlandHolidaySchedule] = [:]) -> String? {
    let published = publishedMainlandHoliday(on: date, calendar: calendar, schedules: schedules)
    if let name = published.name { return name }

    for event in events where event.isAllDay && event.type.isEvent && isChineseMainlandHolidayCalendar(event.calendar) {
        guard calendar.isDay(date, inDays: (event.start, event.end)) else { continue }
        if isMainlandMakeupWorkTitle(event.title) { continue }
        guard let name = shortMainlandHolidayName(from: event.title) else { continue }

        if statutoryHolidayKeys.contains(name) || name == "休息" {
            // Published dates override stale subscriptions. Otherwise trust the event's
            // actual interval, not month/day windows copied from a different year.
            if published.hasSchedule { continue }
            return name
        }

        // One-day festivals (七夕 etc.): EventKit all-day ends next midnight.
        if calendar.isDate(event.start, inSameDayAs: date) {
            return name
        }
    }
    return nil
}

func isChineseMainlandRestDay(from events: [EventModel], date: Date, calendar: Calendar, schedules: [Int: MainlandHolidaySchedule] = [:]) -> Bool {
    let published = publishedMainlandHoliday(on: date, calendar: calendar, schedules: schedules)
    if published.hasSchedule { return published.name != nil }

    let dayEvents = events.filter {
        $0.isAllDay && $0.type.isEvent && isChineseMainlandHolidayCalendar($0.calendar)
            && calendar.isDay(date, inDays: ($0.start, $0.end))
    }
    if dayEvents.contains(where: { isMainlandMakeupWorkTitle($0.title) }) { return false }

    return dayEvents.contains { event in
        // A festival's name alone is not evidence of a published rest arrangement.
        guard isExplicitMainlandRestTitle(event.title),
              let name = shortMainlandHolidayName(from: event.title),
              statutoryHolidayKeys.contains(name) || name == "休息"
        else { return false }
        return true
    }
}

private func publishedMainlandHoliday(on date: Date, calendar displayCalendar: Calendar, schedules: [Int: MainlandHolidaySchedule]) -> (hasSchedule: Bool, name: String?) {
    var calendar = Calendar(identifier: .gregorian)
    // Public holidays belong to civil dates in the displayed grid, not instants in Shanghai.
    calendar.timeZone = displayCalendar.timeZone
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    guard let year = components.year, let month = components.month, let day = components.day else { return (false, nil) }

    // A following year's New Year arrangement can include the previous December.
    if let next = schedules[year + 1]?.day(on: date, calendar: calendar) {
        return (true, next.isOffDay ? shortPublishedHolidayName(next.name) : nil)
    }
    if let schedule = schedules[year] {
        let day = schedule.day(on: date, calendar: calendar)
        return (true, day.flatMap { $0.isOffDay ? shortPublishedHolidayName($0.name) : nil })
    }
    guard let periods = mainlandRestPeriods[year] else { return (false, nil) }

    return (true, periods.first { $0.month == month && $0.days.contains(day) }?.name)
}

private func normalizedHolidayTitle(_ title: String) -> String {
    (title.applyingTransform(StringTransform("Traditional-Simplified"), reverse: false) ?? title)
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

private func isExplicitMainlandRestTitle(_ title: String) -> Bool {
    let text = normalizedHolidayTitle(title).lowercased()
    return ["放假", "休息", "假期", "公休", "补假", "（休）", "(休)", "[休]", "holiday", "day off",
            "non-working day", "non working day"]
        .contains { text.contains($0) }
}
