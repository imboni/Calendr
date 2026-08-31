//
//  MockCalendarSettings.swift
//  Calendr
//
//  Created by Paker on 05/07/2021.
//

#if DEBUG

import RxSwift

class MockCalendarSettings: CalendarSettings {

    let futureEventsDays: Observable<Int>
    let futureEventsDaysObserver: AnyObserver<Int>

    let firstWeekday: Observable<Int>
    let firstWeekdayObserver: AnyObserver<Int>

    let highlightedWeekdays: Observable<[Int]>
    let highlightedWeekdaysObserver: AnyObserver<[Int]>

    let weekCount: Observable<Int>
    let weekCountObserver: AnyObserver<Int>

    let showWeekNumbers: Observable<Bool>
    let toggleWeekNumbers: AnyObserver<Bool>

    let showLunarCalendar: Observable<Bool>
    let toggleLunarCalendar: AnyObserver<Bool>

    let showMainlandHolidays: Observable<Bool>
    let toggleMainlandHolidays: AnyObserver<Bool>

    let showSolarTerms: Observable<Bool>
    let toggleSolarTerms: AnyObserver<Bool>

        weekCount: Int = 6,
        eventDotsStyle: EventDotsStyle = .multiple,
        showDeclinedEvents: Bool = false,
        showAllDayEvents: Bool = true,
        dateHoverOption: Bool = false,
        futureEventsDays: Int = 0,
        preserveSelectedDate: Bool = false,
        calendarAppViewMode: CalendarViewMode = .month,
    ) {
        (self.futureEventsDays, futureEventsDaysObserver) = BehaviorSubject.pipe(value: futureEventsDays)
        (self.firstWeekday, firstWeekdayObserver) = BehaviorSubject.pipe(value: firstWeekday)
        (self.highlightedWeekdays, highlightedWeekdaysObserver) = BehaviorSubject.pipe(value: highlightedWeekdays)
        (self.showWeekNumbers, toggleWeekNumbers) = BehaviorSubject.pipe(value: showWeekNumbers)
        (self.showLunarCalendar, toggleLunarCalendar) = BehaviorSubject.pipe(value: showLunarCalendar)
        (self.showMainlandHolidays, toggleMainlandHolidays) = BehaviorSubject.pipe(value: showMainlandHolidays)
<<<<<<< HEAD
        (self.showSolarTerms, toggleSolarTerms) = BehaviorSubject.pipe(value: showSolarTerms)
=======
>>>>>>> upstream/master
        (self.weekCount, weekCountObserver) = BehaviorSubject.pipe(value: weekCount)
        (self.showDeclinedEvents, toggleDeclinedEvents) = BehaviorSubject.pipe(value: showDeclinedEvents)
        (self.showAllDayEvents, toggleAllDayEvents) = BehaviorSubject.pipe(value: showAllDayEvents)
        (self.dateHoverOption, toggleDateHoverOption) = BehaviorSubject.pipe(value: dateHoverOption)
        (self.eventDotsStyle, eventDotsStyleObserver) = BehaviorSubject.pipe(value: eventDotsStyle)
        (self.calendarScaling, calendarScalingObserver) = BehaviorSubject.pipe(value: calendarScaling)
        (self.calendarTextScaling, calendarTextScalingObserver) = BehaviorSubject.pipe(value: calendarTextScaling)
        (self.textScaling, textScalingObserver) = BehaviorSubject.pipe(value: textScaling)
        (self.preserveSelectedDate, togglePreserveSelectedDate) = BehaviorSubject.pipe(value: preserveSelectedDate)
        (self.calendarAppViewMode, calendarAppViewModeObserver) = BehaviorSubject.pipe(value: calendarAppViewMode)

        self.showMonthOutline = .just(showMonthOutline)
        defaultCalendarApp = .just(.calendar)
    }
}

#endif
