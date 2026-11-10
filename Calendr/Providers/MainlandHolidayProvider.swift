import Foundation
import RxSwift

struct MainlandHolidaySyncState: Equatable {
    enum Issue: Equatable { case unavailable, invalidData, notPublished }
    var schedules: [Int: MainlandHolidaySchedule] = [:]
    var checkedAt: Date?
    var isRefreshing = false
    var issues: [Int: Issue] = [:]
}

protocol MainlandHolidayProviding: AnyObject {
    var state: Observable<MainlandHolidaySyncState> { get }
    func refresh(year: Int?, force: Bool)
}

protocol HolidayDataLoading {
    func data(from url: URL) async throws -> Data
}

final class MainlandHolidayProvider: MainlandHolidayProviding {
    private let subject: BehaviorSubject<MainlandHolidaySyncState>
    var state: Observable<MainlandHolidaySyncState> { subject.asObservable() }
    private let loader: HolidayDataLoading
    private let storage: LocalStorage
    private let dateProvider: DateProviding
    private let disposeBag = DisposeBag()
    private var cached: [Int: CachedHolidaySchedule]
    private var focusedYear: Int?
    private var lastAttempt: [Int: Date] = [:]
    private var inFlight: Set<Int> = []
    private var value: MainlandHolidaySyncState

    /// A forced trigger is the hourly tick; other triggers check the per-year retry deadline.
    init(loader: HolidayDataLoading, storage: LocalStorage, dateProvider: DateProviding, triggers: Observable<Bool>) {
        self.loader = loader
        self.storage = storage
        self.dateProvider = dateProvider
        let saved = storage.data(forKey: holidayCacheKey)
            .flatMap { try? JSONDecoder().decode([Int: CachedHolidaySchedule].self, from: $0) } ?? [:]
        // Validate on disk too; a corrupt or older cache must not poison the calendar.
        cached = saved.filter { year, entry in
            (try? entry.schedule.validate(expectedYear: year)) != nil
                && (try? entry.schedule.verify(officialHTML: entry.officialHTML)) != nil
        }
        value = MainlandHolidaySyncState(schedules: cached.mapValues(\.schedule))
        subject = BehaviorSubject(value: value)
        triggers.subscribe(onNext: { [weak self] force in self?.refresh(year: nil, force: force) })
            .disposed(by: disposeBag)
    }

    func refresh(year: Int?, force: Bool) {
        Task { @MainActor [weak self] in await self?.synchronize(year: year, force: force) }
    }

    /// Main-actor serialization prevents a slow earlier response from overwriting a newer one.
    /// Tests await the real completion instead of sleeping for a network callback.
    @MainActor
    func synchronize(year: Int?, force: Bool) async {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = dateProvider.calendar.timeZone
        let currentYear = calendar.component(.year, from: dateProvider.now)
        if let year { focusedYear = year }
        // Prioritize this year's and next year's announcements. Do not keep polling
        // every historical year the user has ever browsed.
        let watchedYears = [currentYear, currentYear + 1] + (focusedYear.map { [$0, $0 + 1] } ?? [])
        let relevantIssues = value.issues.filter { watchedYears.contains($0.key) }
        if relevantIssues != value.issues {
            value.issues = relevantIssues
            subject.onNext(value)
        }
        var seen = Set<Int>()
        let now = dateProvider.now
        let years = watchedYears.filter { year in
            guard seen.insert(year).inserted, (2007...2100).contains(year), !inFlight.contains(year) else { return false }
            let retryInterval: TimeInterval = value.issues[year].map { $0 == .notPublished ? 3600 : 900 } ?? 3600
            guard let previous = lastAttempt[year], !force else { return true }
            let elapsed = now.timeIntervalSince(previous)
            return elapsed < 0 || elapsed >= retryInterval
        }
        guard !years.isEmpty else { return }
        inFlight.formUnion(years)
        value.isRefreshing = true
        subject.onNext(value)

        // Reserve the whole batch before awaiting. Launch/wake/month switches can overlap.
        for year in years {
            lastAttempt[year] = dateProvider.now
            do {
                let entry = try await fetchVerifiedHoliday(year: year, loader: loader)
                cached[year] = entry
                value.schedules[year] = entry.schedule
                value.issues.removeValue(forKey: year)
                if let data = try? JSONEncoder().encode(cached) {
                    storage.set(data, forKey: holidayCacheKey)
                }
            } catch HolidaySyncError.notPublished {
                // Empty future-year placeholders do not replace a published schedule.
                value.issues[year] = value.schedules[year] == nil ? .notPublished : .unavailable
            } catch HolidaySyncError.invalidData {
                value.issues[year] = .invalidData
            } catch {
                value.issues[year] = .unavailable
            }
            inFlight.remove(year)
            value.checkedAt = dateProvider.now
            value.isRefreshing = !inFlight.isEmpty
            subject.onNext(value) // Refresh visible cells as soon as this year is ready.
        }
    }
}

private let holidayCacheKey = "mainlandHolidayVerifiedCache.v1"

private struct CachedHolidaySchedule: Codable {
    let schedule: MainlandHolidaySchedule
    let officialHTML: Data
}

private func fetchVerifiedHoliday(year: Int, loader: HolidayDataLoading) async throws -> CachedHolidaySchedule {
    // Both URLs serve the same repository. The mirror is availability fallback, not
    // an independent authority; the State Council notice is checked separately.
    let endpoints = [
        "https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/\(year).json",
        "https://cdn.jsdelivr.net/gh/NateScarlet/holiday-cn@master/\(year).json"
    ]
    var failure: Error = HolidaySyncError.notPublished
    for endpoint in endpoints {
        do {
            let data: Data
            do { data = try await loader.data(from: URL(string: endpoint)!) }
            catch HolidaySyncError.http(404) { continue }
            let schedule: MainlandHolidaySchedule
            do { schedule = try JSONDecoder().decode(MainlandHolidaySchedule.self, from: data) }
            catch { throw HolidaySyncError.invalidData }
            guard schedule.year == year else { throw HolidaySyncError.invalidData }
            guard !schedule.papers.isEmpty || !schedule.days.isEmpty else { continue }
            try schedule.validate(expectedYear: year)
            let html = try await loader.data(from: schedule.papers[0])
            try schedule.verify(officialHTML: html)
            return CachedHolidaySchedule(schedule: schedule, officialHTML: html)
        } catch {
            // A placeholder on the other endpoint must not hide invalid data/failures.
            failure = error
        }
    }
    throw failure
}

final class HolidayDataLoader: HolidayDataLoading {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()

    func data(from url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw HolidaySyncError.invalidData }
        guard response.statusCode == 200 else { throw HolidaySyncError.http(response.statusCode) }
        if isOfficialHolidayURL(url) {
            guard let finalURL = response.url, isOfficialHolidayURL(finalURL) else { throw HolidaySyncError.invalidData }
        }
        guard data.count <= 2_000_000 else { throw HolidaySyncError.invalidData }
        return data
    }
}
