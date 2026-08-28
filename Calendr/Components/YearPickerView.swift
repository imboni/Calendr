//
//  YearPickerView.swift
//  Calendr
//
//  Created by Cursor Agent.
//

import AppKit
import RxSwift

class YearPickerView: NSView {

    private let disposeBag = DisposeBag()
    private let yearButtons: [NSButton]
    private let currentYear: Int
    private let onYearSelected: (Int) -> Void

    init(currentYear: Int, onYearSelected: @escaping (Int) -> Void) {
        self.currentYear = currentYear
        self.onYearSelected = onYearSelected

        let startYear = (currentYear / 10) * 10 - 5
        let years = (startYear..<startYear + 20).map { $0 }

        self.yearButtons = years.map { year in
            let button = NSButton()
            button.title = "\(year)"
            button.isBordered = false
            button.bezelStyle = .rounded
            button.setButtonType(.momentaryChange)
            button.font = .systemFont(ofSize: 13)
            button.contentTintColor = year == currentYear ? .controlAccentColor : .labelColor
            button.tag = year
            return button
        }

        super.init(frame: .zero)

        let gridView = NSGridView(numberOfColumns: 4, rows: 5)
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.columnSpacing = 8
        gridView.rowSpacing = 8

        for (index, button) in yearButtons.enumerated() {
            let row = index / 4
            let col = index % 4
            let cell = gridView.cell(atColumnIndex: col, rowIndex: row)
            cell.contentView = button

            button.rx.tap
                .bind { [weak self] in
                    self?.onYearSelected(button.tag)
                }
                .disposed(by: disposeBag)
        }

        addSubview(gridView)

        gridView.edges(equalTo: self, margins: .init(8))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
