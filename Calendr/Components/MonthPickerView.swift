//
//  MonthPickerView.swift
//  Calendr
//

import AppKit

class MonthPickerView: NSView {

    init(currentMonth: Int, calendar: Calendar, onMonthSelected: @escaping (Int) -> Void) {
        super.init(frame: .zero)
        _ = calendar

        wantsLayer = true
        layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

        let titles = (1...12).map { "\($0)月" }
        let grid = PickerGridView(
            columns: 3,
            titles: titles,
            currentIndex: currentMonth - 1
        ) { index in
            onMonthSelected(index + 1)
        }

        addSubview(grid)
        grid.edges(equalTo: self)
    }

    override func updateLayer() {
        super.updateLayer()
        layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
