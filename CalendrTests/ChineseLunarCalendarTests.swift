//
//  ChineseLunarCalendarTests.swift
//  CalendrTests
//

import Foundation
import Testing
@testable import Calendr

@Suite class ChineseLunarCalendarTests {

    @Test func testLunarDateFormatting() {
        let calendar = Calendar(identifier: .gregorian)
        
        // 2024-02-10 is 正月初一 (first day of first lunar month)
        let date1 = calendar.date(from: DateComponents(year: 2024, month: 2, day: 10))!
        let lunar1 = ChineseLunarDate(from: date1)
        #expect(lunar1?.text == "正月")
        #expect(lunar1?.isMonthStart == true)
        
        // 2024-02-11 is 正月初二
        let date2 = calendar.date(from: DateComponents(year: 2024, month: 2, day: 11))!
        let lunar2 = ChineseLunarDate(from: date2)
        #expect(lunar2?.text == "初二")
        #expect(lunar2?.isMonthStart == false)
        
        // 2024-02-24 is 正月十五 (Lantern Festival)
        let date3 = calendar.date(from: DateComponents(year: 2024, month: 2, day: 24))!
        let lunar3 = ChineseLunarDate(from: date3)
        #expect(lunar3?.text == "十五")
        #expect(lunar3?.isMonthStart == false)
    }
    
    @Test func testSolarTerms() {
        // 2026-11-07 should be 立冬
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 11, day: 7))!
        let solarTerm = ChineseSolarTerm(from: date)
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
