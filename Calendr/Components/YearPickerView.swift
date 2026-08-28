//
//  YearPickerView.swift
//  Calendr
//

import AppKit

class YearPickerView: PickerGridView {

    private static let pageSize = 12

    private let selectedYear: Int
    private let onYearSelected: (Int) -> Void
    private var startYear: Int

    init(currentYear: Int, onYearSelected: @escaping (Int) -> Void) {
        self.selectedYear = currentYear
        self.onYearSelected = onYearSelected
        self.startYear = currentYear - 5
        super.init(
            columns: 4,
            titles: [],
            currentIndex: nil
        ) { _ in }
        reloadPage()
    }

    func showPreviousPage() {
        startYear -= Self.pageSize
        reloadPage()
    }

    func showNextPage() {
        startYear += Self.pageSize
        reloadPage()
    }

    private func reloadPage() {
        let years = Array(startYear..<(startYear + Self.pageSize))
        replaceItems(
            titles: years.map { "\($0)" },
            currentIndex: years.firstIndex(of: selectedYear)
        ) { [weak self] index in
            guard let self, years.indices.contains(index) else { return }
            self.onYearSelected(years[index])
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
