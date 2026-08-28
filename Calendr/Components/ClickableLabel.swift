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
    private let disposeBag = DisposeBag()
    private var baseFont = BehaviorSubject<NSFont>(value: .systemFont(ofSize: NSFont.systemFontSize))

    override var font: NSFont? {
        get { super.font }
        set {
            guard let newValue else { return }
            baseFont.onNext(newValue)
        }
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
        self.init(labelWithString: text)
        self.font = font
        self.textColor = color
        self.alignment = align
        setContentHuggingPriority(.fittingSizeCompression, for: .horizontal)
        setUpBindings(scaling)
        setupClickHandling()
    }

    private func setUpBindings(_ scaling: Observable<Double>) {
        Observable
            .combineLatest(baseFont, scaling)
            .map { font, scaling in
                font.withSize(font.pointSize * scaling)
            }
            .bind { [weak self] in
                self?.setFont($0)
            }
            .disposed(by: disposeBag)
    }

    private func setFont(_ font: NSFont) {
        super.font = font
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
