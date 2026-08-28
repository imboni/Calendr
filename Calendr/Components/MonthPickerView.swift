//
//  MonthPickerView.swift
//  Calendr
//
//  Created by Cursor Agent.
//

import AppKit
import RxSwift

class MonthPickerView: NSView {

    private let disposeBag = DisposeBag()
    private let monthButtons: [NSButton]
    private let currentMonth: Int
    private let onMonthSelected: (Int) -> Void

    init(currentMonth: Int, calendar: Calendar, onMonthSelected: @escaping (Int) -> Void) {
        self.currentMonth = currentMonth
        self.onMonthSelected = onMonthSelected

        let monthSymbols = calendar.shortMonthSymbols

        self.monthButtons = (1...12).map { month in
            let button = NSButton()
            button.title = monthSymbols[month - 1]
            button.isBordered = false
            button.bezelStyle = .rounded
            button.setButtonType(.momentaryChange)
            button.font = .systemFont(ofSize: 13)
            button.contentTintColor = month == currentMonth ? .controlAccentColor : .labelColor
            button.tag = month
            return button
        }

        super.init(frame: .zero)

        let gridView = NSGridView(numberOfColumns: 3, rows: 4)
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.columnSpacing = 8
        gridView.rowSpacing = 8

        for (index, button) in monthButtons.enumerated() {
            let row = index / 3
            let col = index % 3
            let cell = gridView.cell(atColumnIndex: col, rowIndex: row)
            cell.contentView = button

            button.rx.tap
                .bind { [weak self] in
                    self?.onMonthSelected(button.tag)
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
