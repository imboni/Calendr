//
//  ClickableLabel.swift
//  Calendr
//
//  Created by Cursor Agent.
//

import AppKit
import RxSwift

class ClickableLabel: Label {

    var onClick: (() -> Void)?

    private var trackingArea: NSTrackingArea?

    convenience init(scaling: Observable<Double>) {
        self.init(text: "", scaling: scaling)
    }

    override init(
        text: String = "",
        font: NSFont? = nil,
        color: NSColor? = nil,
        align: NSTextAlignment = .natural,
        scaling: Observable<Double> = Scaling.observable
    ) {
        super.init(text: text, font: font, color: color, align: align, scaling: scaling)
        setupClickHandling()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupClickHandling()
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
