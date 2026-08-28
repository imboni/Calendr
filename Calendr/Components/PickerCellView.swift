//
//  PickerCellView.swift
//  Calendr
//

import AppKit

class PickerCellView: NSView {

    var onClick: (() -> Void)?

    private let title: String
    private let isCurrent: Bool
    private var isHovered = false {
        didSet { needsDisplay = true }
    }

    init(title: String, isCurrent: Bool) {
        self.title = title
        self.isCurrent = isCurrent
        super.init(frame: .zero)
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        translatesAutoresizingMaskIntoConstraints = true
        addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(handleClick)))
    }

    override var isFlipped: Bool { true }
    override var isOpaque: Bool { false }

    @objc private func handleClick() {
        onClick?()
    }

    override func draw(_ dirtyRect: NSRect) {
        let inset = bounds.insetBy(dx: 3, dy: 3)
        let path = NSBezierPath(roundedRect: inset, xRadius: 5, yRadius: 5)

        if isCurrent {
            NSColor.controlAccentColor.setStroke()
            path.lineWidth = 2
            path.stroke()
        } else if isHovered {
            NSColor.tertiaryLabelColor.setStroke()
            path.lineWidth = 2
            path.stroke()
        }

        let font = NSFont.systemFont(ofSize: 12, weight: isCurrent ? .medium : .regular)
        let color = NSColor.headerTextColor
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let text = NSAttributedString(string: title, attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])
        let textSize = text.size()
        let textRect = CGRect(
            x: bounds.midX - textSize.width / 2,
            y: bounds.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))
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

class PickerGridView: NSView {

    private var cells: [PickerCellView]
    private let columns: Int

    init(columns: Int, titles: [String], currentIndex: Int?, onSelect: @escaping (Int) -> Void) {
        self.columns = columns
        self.cells = []
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        replaceItems(titles: titles, currentIndex: currentIndex, onSelect: onSelect)
    }

    func replaceItems(titles: [String], currentIndex: Int?, onSelect: @escaping (Int) -> Void) {
        cells.forEach { $0.removeFromSuperview() }
        cells = titles.enumerated().map { index, title in
            let isCurrent = currentIndex == index && titles.indices.contains(index)
            return PickerCellView(title: title, isCurrent: isCurrent)
        }
        cells.enumerated().forEach { index, cell in
            cell.onClick = { onSelect(index) }
            cell.translatesAutoresizingMaskIntoConstraints = true
            addSubview(cell)
        }
        needsLayout = true
        layoutSubtreeIfNeeded()
        needsDisplay = true
    }

    override var isFlipped: Bool { true }
    override var isOpaque: Bool { false }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        needsLayout = true
    }

    override func layout() {
        super.layout()
        let count = cells.count
        guard count > 0, columns > 0, bounds.width > 1, bounds.height > 1 else { return }
        let rows = Int(ceil(Double(count) / Double(columns)))
        let width = bounds.width / CGFloat(columns)
        let height = bounds.height / CGFloat(rows)
        for (index, cell) in cells.enumerated() {
            let column = index % columns
            let row = index / columns
            cell.frame = CGRect(
                x: CGFloat(column) * width,
                y: CGFloat(row) * height,
                width: width,
                height: height
            )
            cell.needsDisplay = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
