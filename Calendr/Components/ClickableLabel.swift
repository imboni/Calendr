//
//  ClickableLabel.swift
//  Calendr
//

import AppKit
import RxSwift

class ClickableLabel: Label {

    var onClick: (() -> Void)?

    private var trackingArea: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupClickHandling()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupClickHandling()
    }

    convenience init(scaling: Observable<Double>) {
        self.init(text: "", scaling: scaling)
    }

    convenience init(
        text: String = "",
        font: NSFont? = nil,
        color: NSColor? = nil,
        align: NSTextAlignment = .natural,
        scaling: Observable<Double> = Scaling.observable
    ) {
        self.init(frame: .zero)
        stringValue = text
        isBezeled = false
        drawsBackground = false
        isEditable = false
        isSelectable = false
        self.font = font
        textColor = color
        alignment = align
        setContentHuggingPriority(.fittingSizeCompression, for: .horizontal)
    }

    private func setupClickHandling() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        addGestureRecognizer(clickGesture)
    }

    @objc private func handleClick() {
        onClick?()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea {
            removeTrackingArea(trackingArea)
        }

        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .cursorUpdate],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func cursorUpdate(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }

    override func mouseEntered(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
}
