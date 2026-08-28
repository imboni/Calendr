//
//  PickerCellView.swift
//  Calendr
//

import AppKit

class PickerCellView: NSView {

    var onClick: (() -> Void)?

    private let label: Label
    private let borderLayer = CALayer()
    private var trackingArea: NSTrackingArea?
    private let isCurrent: Bool
    private var isHovered = false {
        didSet { updateBorder() }
    }

    init(title: String, isCurrent: Bool) {
        self.isCurrent = isCurrent
        label = Label(
            text: title,
            font: .systemFont(ofSize: 12, weight: isCurrent ? .medium : .regular),
            color: .headerTextColor,
            align: .center
        )

        super.init(frame: .zero)

        forAutoLayout()
        wantsLayer = true
        clipsToBounds = false
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        borderLayer.cornerRadius = 5
        borderLayer.borderWidth = 2
        layer!.addSublayer(borderLayer)

        addSubview(label)
        label.center(in: self)

        addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(handleClick)))
        updateBorder()
    }

    @objc private func handleClick() {
        onClick?()
    }

    private func updateBorder() {
        if isCurrent {
            borderLayer.borderColor = NSColor.controlAccentColor.cgColor
        } else if isHovered {
            borderLayer.borderColor = NSColor.tertiaryLabelColor.cgColor
        } else {
            borderLayer.borderColor = NSColor.clear.cgColor
        }
    }

    override func layout() {
        super.layout()
        borderLayer.frame = bounds
    }

    override func updateLayer() {
        super.updateLayer()
        updateBorder()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PickerGridView: NSStackView {

    init(columns: Int, titles: [String], currentIndex: Int, onSelect: @escaping (Int) -> Void) {
        super.init(frame: .zero)

        orientation = .vertical
        spacing = 0
        distribution = .fillEqually
        alignment = .width
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)

        let rows = Int(ceil(Double(titles.count) / Double(columns)))
        for row in 0..<rows {
            let rowView = NSStackView()
            rowView.orientation = .horizontal
            rowView.spacing = 0
            rowView.distribution = .fillEqually
            rowView.alignment = .height
            rowView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            rowView.setContentHuggingPriority(.defaultLow, for: .vertical)

            for col in 0..<columns {
                let index = row * columns + col
                guard index < titles.count else { break }
                let cell = PickerCellView(title: titles[index], isCurrent: index == currentIndex)
                cell.onClick = { onSelect(index) }
                rowView.addArrangedSubview(cell)
            }
            addArrangedSubview(rowView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
