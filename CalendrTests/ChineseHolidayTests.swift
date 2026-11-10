//
//  ChineseHolidayTests.swift
//  CalendrTests
//

import Foundation
import Testing
@testable import Calendr

struct ChineseHolidayTests {

    private let calendar = Calendar.gregorian.with(timeZone: TimeZone(identifier: "Asia/Shanghai")!)

    @Test(arguments: [
        (1, 1, "元旦"), (1, 2, "元旦"), (1, 3, "元旦"),
        (2, 5, "春节"), (2, 6, "春节"), (2, 7, "春节"),
        (2, 8, "春节"), (2, 9, "春节"), (2, 10, "春节"),
        (2, 11, "春节"), (2, 12, "春节"), (2, 13, "春节"),
        (4, 3, "清明"), (4, 4, "清明"), (4, 5, "清明"),
        (5, 1, "劳动"), (5, 2, "劳动"), (5, 3, "劳动"),
        (5, 4, "劳动"), (5, 5, "劳动"),
        (6, 9, "端午"), (9, 15, "中秋"),
        (10, 1, "国庆"), (10, 2, "国庆"), (10, 3, "国庆"),
        (10, 4, "国庆"), (10, 5, "国庆"), (10, 6, "国庆"), (10, 7, "国庆")
    ])
    func publishedHolidaysAppearWithoutSubscribedEvents(month: Int, day: Int, name: String) {
        let date: Date = .make(year: 2027, month: month, day: day, timeZone: calendar.timeZone)

        #expect(chineseMainlandHolidayName(from: [], date: date, calendar: calendar) == name)
        #expect(isChineseMainlandRestDay(from: [], date: date, calendar: calendar))
    }

    @Test(arguments: [
        (1, 4), (1, 31), (2, 4), (2, 14), (4, 2), (4, 6),
        (4, 30), (5, 6), (5, 8), (6, 8), (6, 10),
        (9, 14), (9, 16), (9, 26), (9, 30), (10, 8), (10, 9)
    ])
    func holidayBoundariesAndMakeupWorkdaysAreNotRestDays(month: Int, day: Int) {
        let date: Date = .make(year: 2027, month: month, day: day, timeZone: calendar.timeZone)

        #expect(chineseMainlandHolidayName(from: [], date: date, calendar: calendar) == nil)
        #expect(!isChineseMainlandRestDay(from: [], date: date, calendar: calendar))
    }

    @Test func publishedScheduleOverridesStaleSubscription() {
        let date: Date = .make(year: 2027, month: 9, day: 25, timeZone: calendar.timeZone)
        let staleEvent: EventModel = .make(
            start: date,
            end: .make(year: 2027, month: 9, day: 28, timeZone: calendar.timeZone),
            title: "中秋节",
            isAllDay: true,
            calendar: .make(title: "中国大陆节假日", isSubscribed: true)
        )

        #expect(chineseMainlandHolidayName(from: [staleEvent], date: date, calendar: calendar) == nil)
        #expect(!isChineseMainlandRestDay(from: [staleEvent], date: date, calendar: calendar))
    }

    @Test func otherYearsUseEventDatesWithoutFixedMonthDayWindows() {
        let event: EventModel = .make(
            start: .make(year: 2024, month: 9, day: 15, timeZone: calendar.timeZone),
            end: .make(year: 2024, month: 9, day: 18, timeZone: calendar.timeZone),
            title: "中秋节假期",
            isAllDay: true,
            calendar: .make(title: "中国大陆节假日", isSubscribed: true)
        )
        let date: Date = .make(year: 2024, month: 9, day: 17, timeZone: calendar.timeZone)

        #expect(chineseMainlandHolidayName(from: [event], date: date, calendar: calendar) == "中秋")
        #expect(isChineseMainlandRestDay(from: [event], date: date, calendar: calendar))

        // Future-event lists can include holidays that do not intersect today's cell.
        let before: Date = .make(year: 2024, month: 9, day: 14, timeZone: calendar.timeZone)
        let after: Date = .make(year: 2024, month: 9, day: 18, timeZone: calendar.timeZone)
        for outside in [before, after] {
            #expect(chineseMainlandHolidayName(from: [event], date: outside, calendar: calendar) == nil)
            #expect(!isChineseMainlandRestDay(from: [event], date: outside, calendar: calendar))
        }
    }

    @Test func makeupWorkEventIsNotAHoliday() {
        let date: Date = .make(year: 2026, month: 10, day: 10, timeZone: calendar.timeZone)
        let event: EventModel = .make(
            start: date,
            end: .make(year: 2026, month: 10, day: 11, timeZone: calendar.timeZone),
            title: "国庆节（补班）",
            isAllDay: true,
            calendar: .make(title: "中国大陆节假日", isSubscribed: true)
        )

        #expect(chineseMainlandHolidayName(from: [event], date: date, calendar: calendar) == nil)
        #expect(!isChineseMainlandRestDay(from: [event], date: date, calendar: calendar))
    }

    @Test func unannouncedYearIsNotInferredFromPreviousSchedule() {
        let date: Date = .make(year: 2028, month: 2, day: 5, timeZone: calendar.timeZone)

        #expect(chineseMainlandHolidayName(from: [], date: date, calendar: calendar) == nil)
        #expect(!isChineseMainlandRestDay(from: [], date: date, calendar: calendar))
    }

    @Test func traditionalFestivalStillUsesSubscription() {
        let date: Date = .make(year: 2027, month: 2, day: 20, timeZone: calendar.timeZone)
        let event: EventModel = .make(
            start: date,
            end: .make(year: 2027, month: 2, day: 21, timeZone: calendar.timeZone),
            title: "元宵节",
            isAllDay: true,
            calendar: .make(title: "中国大陆节假日", isSubscribed: true)
        )

        #expect(chineseMainlandHolidayName(from: [event], date: date, calendar: calendar) == "元宵")
        #expect(!isChineseMainlandRestDay(from: [event], date: date, calendar: calendar))
    }

    // Independent day-by-day fixtures transcribed from the published notices.
    @Test(arguments: [2026, 2027])
    func entirePublishedYearHasExactlyTheAnnouncedRestDays(year: Int) {
        let expected: Set<Int> = year == 2026
            ? [101, 102, 103, 215, 216, 217, 218, 219, 220, 221, 222, 223,
               404, 405, 406, 501, 502, 503, 504, 505, 619, 620, 621,
               925, 926, 927, 1001, 1002, 1003, 1004, 1005, 1006, 1007]
            : [101, 102, 103, 205, 206, 207, 208, 209, 210, 211, 212, 213,
               403, 404, 405, 501, 502, 503, 504, 505, 609, 915,
               1001, 1002, 1003, 1004, 1005, 1006, 1007]

        for month in 1...12 {
            let start: Date = .make(year: year, month: month, day: 1, timeZone: calendar.timeZone)
            for day in calendar.range(of: .day, in: .month, for: start)! {
                let date: Date = .make(year: year, month: month, day: day, timeZone: calendar.timeZone)
                let isRestDay = expected.contains(month * 100 + day)
                #expect(isChineseMainlandRestDay(from: [], date: date, calendar: calendar) == isRestDay)
                #expect((chineseMainlandHolidayName(from: [], date: date, calendar: calendar) != nil) == isRestDay)
            }
        }
    }

    @Test(arguments: ["Asia/Shanghai", "Asia/Tokyo", "Pacific/Auckland", "Pacific/Kiritimati",
                      "UTC", "Europe/London", "America/Los_Angeles", "Pacific/Honolulu"])
    func holidayUsesDisplayedCivilDate(timeZoneID: String) throws {
        let zone = try #require(TimeZone(identifier: timeZoneID))
        let local = calendar.with(timeZone: zone)
        let date: Date = .make(year: 2027, month: 9, day: 15, timeZone: zone)
        let previous: Date = .make(year: 2027, month: 9, day: 14, hour: 23, timeZone: zone)
        #expect(chineseMainlandHolidayName(from: [], date: date, calendar: local) == "中秋")
        #expect(isChineseMainlandRestDay(from: [], date: date, calendar: local))
        #expect(!isChineseMainlandRestDay(from: [], date: previous, calendar: local))
    }

    @Test(arguments: ["中国大陆节假日", "中國大陸節假日", "中国节假日", "Holidays in China", "China Holidays"])
    func recognizedHolidayCalendars(title: String) {
        #expect(isChineseMainlandHolidayCalendar(.make(title: title)))
        #expect(!isChineseMainlandHolidayCalendar(.make(title: "个人日历")))
        #expect(!isChineseMainlandHolidayCalendar(.make(title: "香港节假日")))
    }

    @Test(arguments: [("清明放假", "清明"), ("清明节假期", "清明"), ("勞動節（休）", "劳动"),
                      ("春節", "春节"), ("Mid-Autumn Festival", "中秋"),
                      ("Chinese New Year's Eve", "除夕"), ("Chinese New Year", "春节"),
                      ("New Year’s Day", "元旦"), ("National Day", "国庆"), ("休息日", "休息")])
    func holidayTitlesAreNotConfusedWithSolarTerms(title: String, expected: String) {
        #expect(shortMainlandHolidayName(from: title) == expected)
    }

    @Test(arguments: ["清明", "清明（节气）", "清明 (节气)", "穀雨", "國慶節（補班）", "春节（工作日）", "Spring Festival (Working Day)"])
    func solarTermsAndMakeupWorkTitlesAreNotRestLabels(title: String) {
        #expect(shortMainlandHolidayName(from: title) == nil)
    }

    @Test func nonWorkingDayIsNotMistakenForMakeupWork() {
        #expect(!isMainlandMakeupWorkTitle("National Day (non-working day)"))
        #expect(shortMainlandHolidayName(from: "National Day (non-working day)") == "国庆")
    }

    @Test func festivalNameAloneDoesNotInventAnUnpublishedRestSchedule() {
        let date: Date = .make(year: 2028, month: 1, day: 26, timeZone: calendar.timeZone)
        let event: EventModel = .make(
            start: date, end: .make(year: 2028, month: 1, day: 27, timeZone: calendar.timeZone),
            title: "春节", isAllDay: true, calendar: .make(title: "中国大陆节假日")
        )
        #expect(chineseMainlandHolidayName(from: [event], date: date, calendar: calendar) == "春节")
        #expect(!isChineseMainlandRestDay(from: [event], date: date, calendar: calendar))
    }

    @Test func workEventOverridesConflictingSubscribedRestEvent() {
        let date: Date = .make(year: 2024, month: 9, day: 14, timeZone: calendar.timeZone)
        let end: Date = .make(year: 2024, month: 9, day: 15, timeZone: calendar.timeZone)
        let rest: EventModel = .make(start: date, end: end, title: "中秋节假期", isAllDay: true,
                                     calendar: .make(title: "中国大陆节假日"))
        let work: EventModel = .make(start: date, end: end, title: "中秋节（补班）", isAllDay: true,
                                     calendar: .make(title: "中国大陆节假日"))
        #expect(isChineseMainlandRestDay(from: [rest], date: date, calendar: calendar))
        #expect(!isChineseMainlandRestDay(from: [rest, work], date: date, calendar: calendar))
        #expect(!isChineseMainlandRestDay(from: [work, rest], date: date, calendar: calendar))
    }

    @Test func personalEventsAndRemindersCannotBecomePublicHolidays() {
        let date: Date = .make(year: 2024, month: 9, day: 17, timeZone: calendar.timeZone)
        let end: Date = .make(year: 2024, month: 9, day: 18, timeZone: calendar.timeZone)
        let personal: EventModel = .make(start: date, end: end, title: "中秋节假期", isAllDay: true,
                                         calendar: .make(title: "个人"))
        let reminder: EventModel = .make(start: date, end: end, title: "中秋节假期", isAllDay: true,
                                         type: .reminder(completed: false), calendar: .make(title: "中国大陆节假日"))
        let timed: EventModel = .make(start: date, end: end, title: "中秋节假期", isAllDay: false,
                                      calendar: .make(title: "中国大陆节假日"))
        #expect(chineseMainlandHolidayName(from: [personal, reminder, timed], date: date, calendar: calendar) == nil)
        #expect(!isChineseMainlandRestDay(from: [personal, reminder, timed], date: date, calendar: calendar))
    }
}
