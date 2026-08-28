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
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let grid = NSGridView(numberOfColumns: 3, rows: 4)
        grid.xPlacement = .fill
        grid.yPlacement = .fill
        grid.rowSpacing = 0
        grid.columnSpacing = 0

        for month in 1...12 {
            let cell = PickerCellView(title: "\(month)月", isCurrent: month == currentMonth)
            cell.onClick = { onMonthSelected(month) }
            grid.cell(atColumnIndex: (month - 1) % 3, rowIndex: (month - 1) / 3).contentView = cell
        }

        addSubview(grid)
        grid.edges(equalTo: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
