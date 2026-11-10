import Foundation
import RxSwift
import Testing
@testable import Calendr

@MainActor
struct MainlandHolidayProviderTests {
    private func schedule(year: Int = 2027) throws -> MainlandHolidaySchedule {
        try JSONDecoder().decode(MainlandHolidaySchedule.self, from: MainlandHolidayFixtures.feedData(year: year))
    }

    @Test func realNoticeMatchesEveryRestAndWorkDate() throws {
        let schedule = try schedule()
        try schedule.validate(expectedYear: 2027)
        try schedule.verify(officialHTML: MainlandHolidayFixtures.noticeData())
        #expect(schedule.days.filter(\.isOffDay).count == 29)
        #expect(schedule.days.filter { !$0.isOffDay }.map(\.date) == ["2027-01-31", "2027-02-14", "2027-05-08", "2027-09-26", "2027-10-09"])
    }

    @Test func mergedMidAutumnAndNationalDayMatchOfficialNotice() throws {
        let merged = try JSONDecoder().decode(MainlandHolidaySchedule.self, from: Data(MainlandHolidayFixtures.combinedFeed.utf8))
        try merged.validate(expectedYear: 2025)
        try merged.verify(officialHTML: Data(MainlandHolidayFixtures.combinedNotice.utf8))
        #expect(merged.days.filter { $0.name.contains("中秋") && $0.isOffDay }.count == 8)
        #expect(shortPublishedHolidayName("国庆节、中秋节") == "国庆")
    }

    @Test func followingYearCanOverridePreviousDecember() throws {
        // Synthetic cross-year case; these are not announced 2028 holidays.
        let original = try schedule(year: 2028)
        let changed = MainlandHolidaySchedule(year: 2028, papers: original.papers, days: original.days + [
            .init(name: "元旦", date: "2027-12-31", isOffDay: true)
        ])
        try changed.validate(expectedYear: 2028)
        let notice = MainlandHolidayFixtures.notice.replacingOccurrences(of: "2027年部分", with: "2028年部分")
            .replacingOccurrences(of: "一、元旦：1月1日（周五）至3日（周日）放假，共3天", with: "一、元旦：2027年12月31日至2028年1月3日放假，共4天")
        // Lookup must honor the following year's dates even when the current year has a built-in schedule.
        let date: Date = .make(year: 2027, month: 12, day: 31)
        #expect(chineseMainlandHolidayName(from: [], date: date, calendar: .gregorian, schedules: [2028: changed]) == "元旦")
        #expect(isChineseMainlandRestDay(from: [], date: date, calendar: .gregorian, schedules: [2028: changed]))
        try changed.verify(officialHTML: Data(notice.utf8))
    }

    @Test(arguments: ["2027-02-30", "2028-02-05", "2027-2-05", "2027-02-06"])
    func invalidOrDuplicateDatesAreRejected(date: String) throws {
        let data = Data(MainlandHolidayFixtures.feed.replacingOccurrences(of: "2027-02-05", with: date).utf8)
        let changed = try JSONDecoder().decode(MainlandHolidaySchedule.self, from: data)
        #expect(throws: (any Error).self) { try changed.validate(expectedYear: 2027) }
    }

    @Test(arguments: [
        ("2027-09-15", "2027-09-16"),
        (#""date":"2027-05-08","isOffDay":false"#, #""date":"2027-05-08","isOffDay":true"#),
        (#""name":"中秋节""#, #""name":"国庆节""#)
    ])
    func plausibleButIncorrectFeedIsRejected(old: String, new: String) throws {
        let changed = try JSONDecoder().decode(MainlandHolidaySchedule.self, from: Data(MainlandHolidayFixtures.feed.replacingOccurrences(of: old, with: new).utf8))
        #expect(throws: (any Error).self) { try changed.verify(officialHTML: MainlandHolidayFixtures.noticeData()) }
    }

    @Test(arguments: ["https://www.gov.cn.example.com/zhengce/fake.htm", "http://www.gov.cn/zhengce/fake.htm", "https://example.com/zhengce/fake.htm", "https://user@www.gov.cn/zhengce/fake.htm"])
    func unofficialSourcesAreRejected(url: String) { #expect(!isOfficialHolidayURL(URL(string: url)!)) }

    @Test func unexpectedNoticeFormatAndWrongYearAreRejected() throws {
        let schedule = try schedule()
        #expect(throws: (any Error).self) { try schedule.validate(expectedYear: 2028) }
        #expect(throws: (any Error).self) { try schedule.verify(officialHTML: Data("<html>maintenance</html>".utf8)) }
        let incomplete = MainlandHolidayFixtures.notice.replacingOccurrences(of: "6月9日", with: "六月九日")
        #expect(throws: (any Error).self) { try schedule.verify(officialHTML: Data(incomplete.utf8)) }
    }

    @Test func syncCachesFutureYearAndRestoresItOffline() async throws {
        let loader = FixtureHolidayLoader()
        let storage = InMemoryStorage()
        let date = MockDateProvider(now: .make(year: 2027, month: 11, day: 1))
        let provider = MainlandHolidayProvider(loader: loader, storage: storage, dateProvider: date, triggers: .never())
        await provider.synchronize(year: nil, force: false)
        var state = try #require(provider.state.currentValue())
        #expect(state.schedules[2028]?.days.count == 34)
        #expect(state.checkedAt == .make(year: 2027, month: 11, day: 1))
        #expect(!state.isRefreshing)
        #expect(state.issues.isEmpty)
        loader.fail = true
        let restored = MainlandHolidayProvider(loader: loader, storage: storage, dateProvider: date, triggers: .never())
        await restored.synchronize(year: nil, force: true)
        state = try #require(restored.state.currentValue())
        #expect(state.schedules[2028]?.days.count == 34)
        #expect(state.issues[2028] == .unavailable)
    }

    @Test func hourlyPollingFailedRetryAndManualRefresh() async throws {
        let loader = FixtureHolidayLoader()
        let date = MockDateProvider(now: .make(year: 2027, month: 11, day: 1))
        let provider = MainlandHolidayProvider(loader: loader, storage: InMemoryStorage(), dateProvider: date, triggers: .never())
        await provider.synchronize(year: nil, force: false)
        let initial = loader.requests.count
        date.now = .make(year: 2027, month: 11, day: 1, hour: 0, minute: 59)
        await provider.synchronize(year: nil, force: false)
        #expect(loader.requests.count == initial)
        date.now = .make(year: 2027, month: 11, day: 1, hour: 1)
        loader.fail = true
        await provider.synchronize(year: nil, force: false)
        #expect(loader.requests.count > initial)
        let failed = loader.requests.count
        date.now = .make(year: 2027, month: 11, day: 1, hour: 1, minute: 14)
        await provider.synchronize(year: nil, force: false)
        #expect(loader.requests.count == failed)
        date.now = .make(year: 2027, month: 11, day: 1, hour: 1, minute: 15)
        loader.fail = false
        await provider.synchronize(year: nil, force: false)
        #expect(loader.requests.count > failed)
        let retried = loader.requests.count
        await provider.synchronize(year: nil, force: true)
        #expect(loader.requests.count > retried)
    }

    @Test func newYearIsRequestedAfterRollover() async {
        let loader = FixtureHolidayLoader()
        let date = MockDateProvider(now: .make(year: 2027, month: 12, day: 31))
        let provider = MainlandHolidayProvider(loader: loader, storage: InMemoryStorage(), dateProvider: date, triggers: .never())
        await provider.synchronize(year: nil, force: false)
        date.now = .make(year: 2028, month: 1, day: 1)
        await provider.synchronize(year: nil, force: false)
        #expect(loader.requests.contains { $0.lastPathComponent == "2029.json" })
    }

    @Test func pollingDoesNotAccumulatePreviouslyViewedYears() async {
        let loader = FixtureHolidayLoader()
        loader.fail = true
        let provider = MainlandHolidayProvider(loader: loader, storage: InMemoryStorage(), dateProvider: MockDateProvider(now: .make(year: 2027, month: 1, day: 1)), triggers: .never())
        await provider.synchronize(year: 2010, force: false)
        loader.fail = false
        await provider.synchronize(year: 2028, force: false)
        loader.requests.removeAll()
        await provider.synchronize(year: nil, force: true)
        #expect(loader.requests.filter { $0.pathExtension == "json" }.map(\.lastPathComponent) == ["2027.json", "2028.json", "2029.json"])
        #expect(provider.state.currentValue()?.issues.isEmpty == true)
    }

    @Test func fallbackMirrorAndEmptyPlaceholderDoNotEraseCachedData() async throws {
        let loader = FixtureHolidayLoader()
        loader.failPrimary = true
        let provider = MainlandHolidayProvider(loader: loader, storage: InMemoryStorage(), dateProvider: MockDateProvider(now: .make(year: 2027, month: 1, day: 1)), triggers: .never())
        await provider.synchronize(year: 2028, force: false)
        #expect(loader.requests.contains { $0.host == "cdn.jsdelivr.net" })
        #expect(provider.state.currentValue()?.schedules[2028] != nil)
        loader.placeholder = true
        await provider.synchronize(year: 2028, force: true)
        #expect(provider.state.currentValue()?.schedules[2028] != nil)
    }

    @Test func unpublishedAndInvalidDataHaveDistinctStates() async throws {
        let loader = FixtureHolidayLoader()
        loader.placeholder = true
        let provider = MainlandHolidayProvider(loader: loader, storage: InMemoryStorage(), dateProvider: MockDateProvider(now: .make(year: 2027, month: 1, day: 1)), triggers: .never())
        await provider.synchronize(year: nil, force: false)
        #expect(provider.state.currentValue()?.issues[2028] == .notPublished)
        loader.placeholder = false
        loader.wrongNotice = true
        await provider.synchronize(year: nil, force: true)
        #expect(provider.state.currentValue()?.issues[2028] == .invalidData)
        #expect(provider.state.currentValue()?.schedules.isEmpty == true)
    }

    @Test func cacheCorruptionIsIgnored() {
        let storage = InMemoryStorage()
        storage.set(Data("bad-json".utf8), forKey: "mainlandHolidayVerifiedCache.v1")
        let provider = MainlandHolidayProvider(loader: FixtureHolidayLoader(), storage: storage, dateProvider: MockDateProvider(), triggers: .never())
        #expect(provider.state.currentValue()?.schedules.isEmpty == true)
    }

    @Test func missingOfficialPageIsAFailureRatherThanAnUnpublishedYear() async {
        let loader = FixtureHolidayLoader()
        loader.missingOfficialPage = true
        let provider = MainlandHolidayProvider(loader: loader, storage: InMemoryStorage(), dateProvider: MockDateProvider(now: .make(year: 2027, month: 1, day: 1)), triggers: .never())
        await provider.synchronize(year: nil, force: false)
        #expect(provider.state.currentValue()?.issues[2028] == .unavailable)
        #expect(provider.state.currentValue()?.schedules.isEmpty == true)
    }

    @Test func overlappingRefreshesDoNotDuplicateRequests() async {
        let loader = FixtureHolidayLoader()
        let started = AsyncStream<Void>.makeStream()
        loader.pauseOnce = { started.continuation.yield(()) }
        let provider = MainlandHolidayProvider(loader: loader, storage: InMemoryStorage(), dateProvider: MockDateProvider(now: .make(year: 2027, month: 1, day: 1)), triggers: .never())
        async let first: Void = provider.synchronize(year: nil, force: false)
        var iterator = started.stream.makeAsyncIterator()
        _ = await iterator.next()
        await provider.synchronize(year: nil, force: true)
        #expect(loader.requests.count == 1)
        loader.resume?.resume()
        await first
        #expect(loader.requests.count == 4) // Two feeds, each with its official notice.
        #expect(provider.state.currentValue()?.isRefreshing == false)
        started.continuation.finish()
    }
}

private final class FixtureHolidayLoader: HolidayDataLoading {
    var requests: [URL] = []
    var fail = false
    var failPrimary = false
    var placeholder = false
    var wrongNotice = false
    var missingOfficialPage = false
    var pauseOnce: (() -> Void)?
    var resume: CheckedContinuation<Void, Never>?
    private var year = 2027
    func data(from url: URL) async throws -> Data {
        requests.append(url)
        if let pause = pauseOnce {
            pauseOnce = nil
            await withCheckedContinuation { continuation in
                resume = continuation
                pause()
            }
        }
        if fail || (failPrimary && url.host == "raw.githubusercontent.com") { throw URLError(.notConnectedToInternet) }
        if url.pathExtension == "json" {
            year = Int(url.deletingPathExtension().lastPathComponent)!
            if placeholder { return Data("{\"year\":\(year),\"papers\":[],\"days\":[]}".utf8) }
            return MainlandHolidayFixtures.feedData(year: year)
        }
        if missingOfficialPage { throw HolidaySyncError.http(404) }
        return wrongNotice ? Data("wrong notice".utf8) : MainlandHolidayFixtures.noticeData(year: year)
    }
}

private extension Observable {
    // BehaviorSubject emits synchronously on subscription; no blocking or timing assumptions.
    func currentValue() -> Element? {
        var value: Element?
        let disposable = take(1).subscribe(onNext: { value = $0 })
        disposable.dispose()
        return value
    }
}
