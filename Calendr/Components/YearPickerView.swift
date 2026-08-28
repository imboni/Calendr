//
//  YearPickerView.swift
//  Calendr
//

import AppKit
import RxSwift

class YearPickerView: NSView {

    private let disposeBag = DisposeBag()

    init(currentYear: Int, onYearSelected: @escaping (Int) -> Void) {
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let startYear = (currentYear / 10) * 10 - 5
        let years = Array(startYear..<(startYear + 20))

        let grid = NSStackView()
        grid.orientation = .vertical
        grid.spacing = 6
        grid.distribution = .fillEqually

        for row in 0..<5 {
            let rowView = NSStackView()
            rowView.spacing = 6
            rowView.distribution = .fillEqually
            for col in 0..<4 {
                let year = years[row * 4 + col]
                let button = NSButton(title: "\(year)", target: nil, action: nil)
                button.bezelStyle = .flexiblePush
                button.isBordered = true
                button.font = .systemFont(ofSize: 13, weight: year == currentYear ? .semibold : .regular)
                button.contentTintColor = year == currentYear ? .controlAccentColor : .labelColor
                button.setContentHuggingPriority(.defaultLow, for: .horizontal)
                button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                button.rx.tap
                    .bind { onYearSelected(year) }
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
