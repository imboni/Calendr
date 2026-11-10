import Foundation
import Testing
@testable import Calendr

struct ChineseCalendar2027Tests {
    // Golden civil-date data from the Hong Kong Observatory, downloaded 2026-11-09.
    // https://www.hko.gov.hk/tc/gts/time/calendar/text/files/T2027c.txt
    // Only presentation is normalized: simplified characters, 十一月 → 冬月, 十二月 → 腊月.
    private let months = [
        "廿四 廿五 廿六 廿七 廿八:小寒 廿九 三十 腊月 初二 初三 初四 初五 初六 初七 初八 初九 初十 十一 十二 十三:大寒 十四 十五 十六 十七 十八 十九 二十 廿一 廿二 廿三 廿四",
        "廿五 廿六 廿七 廿八:立春 廿九 正月 初二 初三 初四 初五 初六 初七 初八 初九 初十 十一 十二 十三 十四:雨水 十五 十六 十七 十八 十九 二十 廿一 廿二 廿三",
        "廿四 廿五 廿六 廿七 廿八 廿九:惊蛰 三十 二月 初二 初三 初四 初五 初六 初七 初八 初九 初十 十一 十二 十三 十四:春分 十五 十六 十七 十八 十九 二十 廿一 廿二 廿三 廿四",
        "廿五 廿六 廿七 廿八 廿九:清明 三十 三月 初二 初三 初四 初五 初六 初七 初八 初九 初十 十一 十二 十三 十四:谷雨 十五 十六 十七 十八 十九 二十 廿一 廿二 廿三 廿四",
        "廿五 廿六 廿七 廿八 廿九 四月:立夏 初二 初三 初四 初五 初六 初七 初八 初九 初十 十一 十二 十三 十四 十五 十六:小满 十七 十八 十九 二十 廿一 廿二 廿三 廿四 廿五 廿六",
        "廿七 廿八 廿九 三十 五月 初二:芒种 初三 初四 初五 初六 初七 初八 初九 初十 十一 十二 十三 十四 十五 十六 十七:夏至 十八 十九 二十 廿一 廿二 廿三 廿四 廿五 廿六",
        "廿七 廿八 廿九 六月 初二 初三 初四:小暑 初五 初六 初七 初八 初九 初十 十一 十二 十三 十四 十五 十六 十七 十八 十九 二十:大暑 廿一 廿二 廿三 廿四 廿五 廿六 廿七 廿八",
        "廿九 七月 初二 初三 初四 初五 初六 初七:立秋 初八 初九 初十 十一 十二 十三 十四 十五 十六 十七 十八 十九 二十 廿一 廿二:处暑 廿三 廿四 廿五 廿六 廿七 廿八 廿九 三十",
        "八月 初二 初三 初四 初五 初六 初七 初八:白露 初九 初十 十一 十二 十三 十四 十五 十六 十七 十八 十九 二十 廿一 廿二 廿三:秋分 廿四 廿五 廿六 廿七 廿八 廿九 九月",
        "初二 初三 初四 初五 初六 初七 初八 初九:寒露 初十 十一 十二 十三 十四 十五 十六 十七 十八 十九 二十 廿一 廿二 廿三 廿四:霜降 廿五 廿六 廿七 廿八 廿九 十月 初二 初三",
        "初四 初五 初六 初七 初八 初九 初十:立冬 十一 十二 十三 十四 十五 十六 十七 十八 十九 二十 廿一 廿二 廿三 廿四 廿五:小雪 廿六 廿七 廿八 廿九 三十 冬月 初二 初三",
        "初四 初五 初六 初七 初八 初九 初十:大雪 十一 十二 十三 十四 十五 十六 十七 十八 十九 二十 廿一 廿二 廿三 廿四 廿五:冬至 廿六 廿七 廿八 廿九 三十 腊月 初二 初三 初四"
    ]

    @Test func everyDayMatchesObservatoryLunarAndSolarTable() {
        let calendar = Calendar.gregorian.with(timeZone: .shanghai)
        for (monthIndex, row) in months.enumerated() {
            for (dayIndex, entry) in row.split(separator: " ").enumerated() {
                let expected = entry.split(separator: ":").map(String.init)
                let date: Date = .make(year: 2027, month: monthIndex + 1, day: dayIndex + 1, timeZone: .shanghai)
                #expect(ChineseLunarDate(from: date, calendar: calendar)?.text == expected[0])
                #expect(ChineseSolarTerm(from: date, calendar: calendar)?.text == (expected.count == 2 ? expected[1] : nil))
            }
        }
    }
}
