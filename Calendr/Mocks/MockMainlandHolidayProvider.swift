#if DEBUG
import RxSwift

final class MockMainlandHolidayProvider: MainlandHolidayProviding {
    let subject = BehaviorSubject(value: MainlandHolidaySyncState())
    var state: Observable<MainlandHolidaySyncState> { subject.asObservable() }
    var requestedYears: [Int?] = []
    func refresh(year: Int?, force: Bool) { requestedYears.append(year) }
}
#endif
