import Foundation

/// Civil dates are stored verbatim; a user's time zone must never move a holiday.
struct MainlandHolidaySchedule: Codable, Equatable {
    struct Day: Codable, Equatable {
        let name: String
        let date: String
        let isOffDay: Bool
    }

    let year: Int
    let papers: [URL]
    let days: [Day]

    func day(on date: Date, calendar: Calendar) -> Day? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let parts = gregorian.dateComponents([.year, .month, .day], from: date)
        let key = String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
        return days.first { $0.date == key }
    }

    func validate(expectedYear: Int) throws {
        guard year == expectedYear, (2007...2100).contains(year), papers.count == 1,
              papers.allSatisfy(isOfficialHolidayURL), !days.isEmpty, days.count <= 100,
              Set(days.map(\.date)).count == days.count else { throw HolidaySyncError.invalidData }

        var festivals = Set<String>()
        for day in days {
            guard let date = holidayCivilDate(day.date),
                  (date.year == year || (date.year == year - 1 && date.month == 12)),
                  let names = holidayNames(day.name) else { throw HolidaySyncError.invalidData }
            if day.isOffDay { festivals.formUnion(names) }
        }
        guard festivals == Set(holidayNamesByTitle.values) else { throw HolidaySyncError.invalidData }
    }

    /// A URL in a feed is not proof: compare every rest/work date with the actual notice.
    func verify(officialHTML data: Data) throws {
        guard let html = String(data: data, encoding: .utf8),
              plainHolidayText(html).contains("国务院办公厅关于\(year)年部分节假日安排的通知")
        else { throw HolidaySyncError.invalidData }

        let paragraphs = holidayMatches(#"(?is)<p\b[^>]*>(.*?)</p>"#, html).map { plainHolidayText($0[1]) }
        var officialDays: [String: Day] = [:]
        var festivals = Set<String>()
        for paragraph in paragraphs {
            let sections = holidayMatches(#"^[一二三四五六七八九十]+、([^：:]+)[：:](.+)$"#, paragraph)
            guard let section = sections.first else { continue }
            guard let names = holidayNames(section[1]), festivals.isDisjoint(with: names) else {
                throw HolidaySyncError.invalidData
            }
            festivals.formUnion(names)
            let body = section[2].replacingOccurrences(of: #"[（(][^）)]*[）)]"#, with: "", options: .regularExpression)
            let clauses = body.split(separator: "。", omittingEmptySubsequences: true).map(String.init)
            guard let rest = clauses.first else { throw HolidaySyncError.invalidData }
            let datePattern = #"(?:(\d{4})年)?(?:(\d{1,2})月)?(\d{1,2})日"#
            let ranges = holidayMatches("^(" + datePattern + ")(?:至(" + datePattern + "))?放假(?:调休)?(?:[0-9]+天)?(?:，(?:共[0-9]+天|与周末连休|不调休))*$", rest)
            guard let range = ranges.first,
                  let start = holidayNoticeDate(range[1], year: year, month: nil),
                  let end = range[5].isEmpty ? start : holidayNoticeDate(range[5], year: start.year, month: start.month)
            else { throw HolidaySyncError.invalidData }

            let count = holidayGregorian.dateComponents([.day], from: start.value, to: end.value).day! + 1
            guard (1...20).contains(count) else { throw HolidaySyncError.invalidData }
            if let declared = holidayMatches(#"(?:共|放假)(\d+)天"#, rest).first {
                guard Int(declared[1]) == count else { throw HolidaySyncError.invalidData }
            }
            for offset in 0..<count {
                let date = holidayGregorian.date(byAdding: .day, value: offset, to: start.value)!
                let parts = holidayGregorian.dateComponents([.year, .month, .day], from: date)
                let key = String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
                guard officialDays[key] == nil else { throw HolidaySyncError.invalidData }
                officialDays[key] = Day(name: names.sorted().joined(separator: "、"), date: key, isOffDay: true)
            }
            for work in clauses.dropFirst() {
                guard work.hasSuffix("上班") else { throw HolidaySyncError.invalidData }
                for text in work.dropLast(2).split(separator: "、") {
                    guard let date = holidayNoticeDate(String(text), year: year, month: nil),
                          officialDays[date.key] == nil else { throw HolidaySyncError.invalidData }
                    officialDays[date.key] = Day(name: names.sorted().joined(separator: "、"), date: date.key, isOffDay: false)
                }
            }
        }
        guard festivals == Set(holidayNamesByTitle.values), officialDays.count == days.count else {
            throw HolidaySyncError.invalidData
        }
        for day in days {
            guard let official = officialDays[day.date], official.isOffDay == day.isOffDay,
                  holidayNames(official.name) == holidayNames(day.name) else { throw HolidaySyncError.invalidData }
        }
    }
}

enum HolidaySyncError: Error {
    case invalidData
    case notPublished
    case http(Int)
}

func isOfficialHolidayURL(_ url: URL) -> Bool {
    url.scheme == "https" && url.host == "www.gov.cn" && url.port == nil
        && url.user == nil && url.password == nil
        && (url.path.hasPrefix("/zhengce/") || url.path.hasPrefix("/gongbao/"))
        && (url.path.hasSuffix(".htm") || url.path.hasSuffix(".html"))
}

func shortPublishedHolidayName(_ name: String) -> String {
    let names = holidayNames(name) ?? []
    // Combined Mid-Autumn / National Day periods fit in the cell as 国庆.
    return ["国庆", "中秋", "春节", "元旦", "清明", "劳动", "端午"].first(where: names.contains) ?? name
}

private let holidayNamesByTitle = [
    "元旦": "元旦", "春节": "春节", "清明节": "清明", "劳动节": "劳动",
    "端午节": "端午", "中秋节": "中秋", "国庆节": "国庆"
]

private func holidayNames(_ value: String) -> Set<String>? {
    let parts = value.components(separatedBy: CharacterSet(charactersIn: "、和与,"))
    let names = parts.compactMap { holidayNamesByTitle[$0] ?? (holidayNamesByTitle.values.contains($0) ? $0 : nil) }
    return names.count == parts.count && Set(names).count == names.count ? Set(names) : nil
}

private let holidayGregorian: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
}()

private struct HolidayCivilDate {
    let year: Int
    let month: Int
    let day: Int
    let value: Date
    var key: String { String(format: "%04d-%02d-%02d", year, month, day) }
}

private func holidayCivilDate(_ key: String) -> HolidayCivilDate? {
    guard let match = holidayMatches(#"^(\d{4})-(\d{2})-(\d{2})$"#, key).first,
          let year = Int(match[1]), let month = Int(match[2]), let day = Int(match[3]),
          let date = holidayGregorian.date(from: DateComponents(year: year, month: month, day: day)),
          holidayGregorian.dateComponents([.year, .month, .day], from: date) == DateComponents(year: year, month: month, day: day)
    else { return nil }
    return HolidayCivilDate(year: year, month: month, day: day, value: date)
}

private func holidayNoticeDate(_ text: String, year: Int, month: Int?) -> HolidayCivilDate? {
    guard let match = holidayMatches(#"^(?:(\d{4})年)?(?:(\d{1,2})月)?(\d{1,2})日$"#, text).first,
          let month = Int(match[2]) ?? month, let day = Int(match[3]) else { return nil }
    return holidayCivilDate(String(format: "%04d-%02d-%02d", Int(match[1]) ?? year, month, day))
}

private func plainHolidayText(_ html: String) -> String {
    html.replacingOccurrences(of: #"(?is)<(script|style)\b[^>]*>.*?</\1>"#, with: "", options: .regularExpression)
        .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
        .replacingOccurrences(of: "&nbsp;", with: "")
        .replacingOccurrences(of: "&#160;", with: "")
        .filter { !$0.isWhitespace }
}

private func holidayMatches(_ pattern: String, _ text: String) -> [[String]] {
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
    return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).map { match in
        (0..<match.numberOfRanges).map { index in
            Range(match.range(at: index), in: text).map { String(text[$0]) } ?? ""
        }
    }
}
