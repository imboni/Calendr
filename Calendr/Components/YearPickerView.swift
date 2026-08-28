//
//  YearPickerView.swift
//  Calendr
//

import AppKit

class YearPickerView: NSView {

    init(currentYear: Int, onYearSelected: @escaping (Int) -> Void) {
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

        let startYear = currentYear - 5
        let years = Array(startYear..<(startYear + 12))
        let currentIndex = years.firstIndex(of: currentYear) ?? 5

        let grid = PickerGridView(
            columns: 4,
            titles: years.map { "\($0)" },
            currentIndex: currentIndex
        ) { index in
            onYearSelected(years[index])
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
