//
//  MonthPickerView.swift
//  Calendr
//

import AppKit
import RxSwift

class MonthPickerView: NSView {

    private let disposeBag = DisposeBag()

    init(currentMonth: Int, calendar: Calendar, onMonthSelected: @escaping (Int) -> Void) {
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let titles = (1...12).map { "\($0)月" }

        let grid = NSStackView()
        grid.orientation = .vertical
        grid.spacing = 6
        grid.distribution = .fillEqually

        for row in 0..<4 {
            let rowView = NSStackView()
            rowView.spacing = 6
            rowView.distribution = .fillEqually
            for col in 0..<3 {
                let month = row * 3 + col + 1
                let button = NSButton(title: titles[month - 1], target: nil, action: nil)
                button.bezelStyle = .flexiblePush
                button.isBordered = true
                button.font = .systemFont(ofSize: 13, weight: month == currentMonth ? .semibold : .regular)
                button.contentTintColor = month == currentMonth ? .controlAccentColor : .labelColor
                button.setContentHuggingPriority(.defaultLow, for: .horizontal)
                button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                button.rx.tap
                    .bind { onMonthSelected(month) }
                    .disposed(by: disposeBag)
                rowView.addArrangedSubview(button)
            }
            grid.addArrangedSubview(rowView)
        }

        addSubview(grid)
        grid.edges(equalTo: self, margins: .init(8))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
