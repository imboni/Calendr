//
//  YearPickerView.swift
//  Calendr
//

import AppKit

class YearPickerView: NSView {

    init(currentYear: Int, onYearSelected: @escaping (Int) -> Void) {
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let startYear = currentYear - 5
        let years = Array(startYear..<(startYear + 12))

        let grid = NSGridView(numberOfColumns: 4, rows: 3)
        grid.xPlacement = .fill
        grid.yPlacement = .fill
        grid.rowSpacing = 0
        grid.columnSpacing = 0

        for (index, year) in years.enumerated() {
            let cell = PickerCellView(title: "\(year)", isCurrent: year == currentYear)
            cell.onClick = { onYearSelected(year) }
            grid.cell(atColumnIndex: index % 4, rowIndex: index / 4).contentView = cell
        }

        addSubview(grid)
        grid.edges(equalTo: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
