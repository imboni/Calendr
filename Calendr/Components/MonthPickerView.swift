//
//  MonthPickerView.swift
//  Calendr
//

import AppKit

class MonthPickerView: PickerGridView {

    init(currentMonth: Int, calendar: Calendar, onMonthSelected: @escaping (Int) -> Void) {
        _ = calendar
        super.init(
            columns: 3,
            titles: (1...12).map { "\($0)月" },
            currentIndex: currentMonth - 1
        ) { index in
            onMonthSelected(index + 1)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
