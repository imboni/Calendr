//
//  ChineseLunarCalendarTests.swift
//  CalendrTests
//

import Foundation
import Testing
@testable import Calendr

@Suite class ChineseLunarCalendarTests {

    // Hong Kong Observatory 2027 Gregorian / lunar calendar (UTC+8 civil dates).
    // https://www.hko.gov.hk/tc/gts/time/calendar/text/files/T2027c.txt
    @Test(arguments: [(1, 5, "小寒"), (1, 20, "大寒"), (2, 4, "立春"), (2, 19, "雨水"),
                      (3, 6, "惊蛰"), (3, 21, "春分"), (4, 5, "清明"), (4, 20, "谷雨"),
                      (5, 6, "立夏"), (5, 21, "小满"), (6, 6, "芒种"), (6, 21, "夏至"),
                      (7, 7, "小暑"), (7, 23, "大暑"), (8, 8, "立秋"), (8, 23, "处暑"),
                      (9, 8, "白露"), (9, 23, "秋分"), (10, 8, "寒露"), (10, 23, "霜降"),
                      (11, 7, "立冬"), (11, 22, "小雪"), (12, 7, "大雪"), (12, 22, "冬至")])
    func testAll2027SolarTerms(month: Int, day: Int, expected: String) {
        let calendar = Calendar.gregorian.with(timeZone: .shanghai)
        let date: Date = .make(year: 2027, month: month, day: day, timeZone: .shanghai)
        #expect(ChineseSolarTerm(from: date, calendar: calendar)?.text == expected)
    }

    @Test(arguments: ["Asia/Shanghai", "Pacific/Auckland", "Pacific/Kiritimati", "UTC", "America/Los_Angeles"])
    func testLunarAndSolarLabelsFollowGridDate(timeZoneID: String) throws {
        let zone = try #require(TimeZone(identifier: timeZoneID))
        let calendar = Calendar.gregorian.with(timeZone: zone)
        let newYear: Date = .make(year: 2027, month: 2, day: 6, timeZone: zone)
        let midAutumn: Date = .make(year: 2027, month: 9, day: 15, timeZone: zone)
        let qingming: Date = .make(year: 2027, month: 4, day: 5, timeZone: zone)
        #expect(ChineseLunarDate(from: newYear, calendar: calendar)?.fullText == "正月初一")
        #expect(ChineseLunarDate(from: midAutumn, calendar: calendar)?.fullText == "八月十五")
        #expect(ChineseSolarTerm(from: qingming, calendar: calendar)?.text == "清明")
    }

    @Test func testHolidaySolarTermAndLunarTogglePriority() {
        let calendar = Calendar.gregorian.with(timeZone: .shanghai)
        let date: Date = .make(year: 2027, month: 4, day: 5, timeZone: .shanghai)
        for holiday in [false, true] {
            for solar in [false, true] {
                for lunar in [false, true] {
                    let plugin = BoniChineseCalendarCellPlugin(for: date, events: [], calendar: calendar,
                        showLunarCalendar: lunar, showMainlandHolidays: holiday, showSolarTerms: solar)
                    #expect(plugin.text == (holiday || solar ? "清明" : lunar ? "廿九" : nil))
                    if holiday { #expect(plugin.textColor == .systemRed.withAlphaComponent(0.8)) }
                    else if solar { #expect(plugin.textColor == .systemBrown.withAlphaComponent(0.85)) }
                }
            }
        }
    }

    @Test func testLunarDateFormatting() {
        let calendar = Calendar(identifier: .gregorian)
        
        // 2024-02-10 is 正月初一 (first day of first lunar month)
        let date1 = calendar.date(from: DateComponents(year: 2024, month: 2, day: 10))!
        let lunar1 = ChineseLunarDate(from: date1, calendar: calendar)
        #expect(lunar1?.text == "正月")
        #expect(lunar1?.isMonthStart == true)
        
        // 2024-02-11 is 正月初二
        let date2 = calendar.date(from: DateComponents(year: 2024, month: 2, day: 11))!
        let lunar2 = ChineseLunarDate(from: date2, calendar: calendar)
        #expect(lunar2?.text == "初二")
        #expect(lunar2?.isMonthStart == false)
        
        // 2024-02-24 is 正月十五 (Lantern Festival)
        let date3 = calendar.date(from: DateComponents(year: 2024, month: 2, day: 24))!
        let lunar3 = ChineseLunarDate(from: date3, calendar: calendar)
        #expect(lunar3?.text == "十五")
        #expect(lunar3?.isMonthStart == false)
    }
    
    @Test func testSolarTerms() {
        // 2026-11-07 should be 立冬
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 11, day: 7))!
        let solarTerm = ChineseSolarTerm(from: date, calendar: calendar)
        #expect(solarTerm?.text == "立冬")
    }
    
    @Test func testPluginPriority() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2024, month: 2, day: 10))!
        
        // Test with all toggles on
        let plugin1 = BoniChineseCalendarCellPlugin(
            for: date,
            events: [],
            calendar: calendar,
            showLunarCalendar: true,
            showMainlandHolidays: false,
            showSolarTerms: false
        )
        #expect(plugin1.text == "正月")
        
        // Test with lunar off, solar on (solar independent of lunar)
        let plugin2 = BoniChineseCalendarCellPlugin(
            for: date,
            events: [],
            calendar: calendar,
            showLunarCalendar: false,
            showMainlandHolidays: false,
            showSolarTerms: true
        )
        #expect(plugin2.text == nil) // No solar term on this day
        
        // Test with all off
        let plugin3 = BoniChineseCalendarCellPlugin(
            for: date,
            events: [],
            calendar: calendar,
            showLunarCalendar: false,
            showMainlandHolidays: false,
            showSolarTerms: false
        )
        #expect(plugin3.text == nil)
    }
}
