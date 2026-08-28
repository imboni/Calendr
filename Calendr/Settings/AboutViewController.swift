//
//  AboutViewController.swift
//  Calendr
//
//  Created by Paker on 18/02/2021.
//

import Cocoa
import RxSwift

class AboutViewController: NSViewController, SettingsUI {

    private let quitButton: NSButton
    private let originalLinkView: NSTextView
    private let editionLinkView: NSTextView
    private let newVersionButton: NSButton
    private let autoCheckForUpdatesCheckbox: Checkbox
    private let launchServices: LaunchServiceProviding
    private let autoUpdater: AutoUpdating
    private let viewModel: SettingsViewModel

    private let disposeBag = DisposeBag()

    init(autoUpdater: AutoUpdating, launchServices: LaunchServiceProviding, settingsViewModel: SettingsViewModel) {

        self.autoUpdater = autoUpdater
        self.launchServices = launchServices
        self.viewModel = settingsViewModel

        originalLinkView = Self.makeLinkView("https://github.com/pakerwreah/Calendr")
        editionLinkView = Self.makeLinkView("https://github.com/imboni/Calendr")

        newVersionButton = NSButton()

        autoCheckForUpdatesCheckbox = Checkbox(title: Strings.AutoUpdate.checkAutomatically)
        autoCheckForUpdatesCheckbox.setContentHuggingPriority(.required, for: .horizontal)

        quitButton = NSButton()

        super.init(nibName: nil, bundle: nil)

        quitButton.title = Strings.quit
        quitButton.target = self
        quitButton.action = #selector(terminate)
        quitButton.refusesFirstResponder = true

        newVersionButton.target = self
        newVersionButton.refusesFirstResponder = true
        newVersionButton.bezelStyle = .accessoryBarAction

        setUpBindings()
    }

    private static func makeLinkView(_ url: String) -> NSTextView {
        let view = NSTextView()
        view.string = url
        view.backgroundColor = .clear
        view.linkTextAttributes?[.underlineColor] = NSColor.clear
        view.isAutomaticLinkDetectionEnabled = true
        view.checkTextInDocument(nil)
        view.isEditable = false
        view.alignment = .center
        view.height(equalTo: 15)
        return view
    }

    @objc func terminate() {
        launchServices.terminate()
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        let stackView = NSStackView(views: [
            Label(text: "Calendr 中国版", font: .systemFont(ofSize: 16, weight: .semibold), align: .center),
            Label(text: "基于 pakerwreah/Calendr 完善", font: .systemFont(ofSize: 12), color: .secondaryLabelColor, align: .center),
            .spacer(height: 0),
            Label(text: BuildConfig.appVersion, font: .systemFont(ofSize: 13), align: .center),
            Label(text: "\(BuildConfig.date) - \(BuildConfig.time)", color: .secondaryLabelColor, align: .center),
            .spacer(height: 4),
            Label(text: #"¯\_(ツ)_/¯"#, font: .systemFont(ofSize: 16), align: .center),
            .spacer(height: 4),
            Label(text: "© 2020 - \(BuildConfig.date.suffix(4)) Carlos Enumo", align: .center),
            originalLinkView,
            Label(text: "中国版 © 2026 Boni", align: .center),
            editionLinkView,
            .spacer(height: Constants.sectionSpacing),
            newVersionButton,
            .spacer(height: 0),
            autoCheckForUpdatesCheckbox,
            .spacer(height: Constants.sectionSpacing),
            quitButton
        ])
        .with(insets: .init(vertical: Constants.sectionSpacing))
        .with(orientation: .vertical)
        .with(alignment: .centerX)

        view.addSubview(stackView)

        stackView.edges(equalTo: view)
    }

    private func setUpBindings() {

        autoUpdater.status.observe(on: MainScheduler.instance).bind { [weak self] status in
            guard let self else { return }
            switch status {
            case .initial:
                newVersionButton.title = Strings.AutoUpdate.checkForUpdates
                newVersionButton.action = #selector(checkForUpdates)
                newVersionButton.isEnabled = true

            case .fetching:
                newVersionButton.isEnabled = false
                newVersionButton.title = Strings.AutoUpdate.fetchingReleases

            case .downloading(let version):
                newVersionButton.isEnabled = false
                newVersionButton.title = Strings.AutoUpdate.downloading(version)

            case .newVersion(let version):
                newVersionButton.title = Strings.AutoUpdate.newVersion(version)
                newVersionButton.action = #selector(installUpdates)
                newVersionButton.isEnabled = true
            }
        }
        .disposed(by: disposeBag)

        bind(
            control: autoCheckForUpdatesCheckbox,
            observable: viewModel.autoCheckForUpdates,
            observer: viewModel.toggleAutoCheckForUpdates
        )
        .disposed(by: disposeBag)
    }

    @objc private func checkForUpdates() {
        autoUpdater.checkRelease()
    }

    @objc private func installUpdates() {
        autoUpdater.downloadAndInstall()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
