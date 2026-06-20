//
//  ViewController.swift
//  tvos-darkmode

import UIKit

struct AppearancePresentation {
    let text: String
    let backgroundColor: UIColor
    let textColor: UIColor

    static func resolve(for style: UIUserInterfaceStyle) -> AppearancePresentation {
        switch style {
        case .dark:
            return AppearancePresentation(
                text: "Dark Mode",
                backgroundColor: .black,
                textColor: .white
            )
        case .light:
            return AppearancePresentation(
                text: "Light Mode",
                backgroundColor: .white,
                textColor: .black
            )
        default:
            return AppearancePresentation(
                text: "Automatic Mode",
                backgroundColor: .darkGray,
                textColor: .white
            )
        }
    }

}

struct AppearanceTransitionUpdate: Equatable {
    let style: UIUserInterfaceStyle
    let shouldRender: Bool
    let shouldAnnounce: Bool
}

struct AppearanceTransitionState {
    private var currentStyle: UIUserInterfaceStyle?
    private var lastCommunicatedStyle: UIUserInterfaceStyle?
    private var isVisible = false
    private var isActive = false

    mutating func load(style: UIUserInterfaceStyle) -> AppearanceTransitionUpdate {
        currentStyle = style
        lastCommunicatedStyle = style
        return AppearanceTransitionUpdate(
            style: style,
            shouldRender: true,
            shouldAnnounce: false
        )
    }

    mutating func transition(to style: UIUserInterfaceStyle) -> AppearanceTransitionUpdate? {
        guard currentStyle != style else {
            return nil
        }

        currentStyle = style
        return update(style: style, shouldRender: true)
    }

    mutating func setVisible(_ visible: Bool) -> AppearanceTransitionUpdate? {
        guard isVisible != visible else {
            return nil
        }

        isVisible = visible
        return pendingAnnouncement()
    }

    mutating func setActive(_ active: Bool) -> AppearanceTransitionUpdate? {
        guard isActive != active else {
            return nil
        }

        isActive = active
        return pendingAnnouncement()
    }

    private mutating func pendingAnnouncement() -> AppearanceTransitionUpdate? {
        guard let currentStyle = currentStyle,
              isVisible,
              isActive,
              lastCommunicatedStyle != currentStyle else {
            return nil
        }

        return update(style: currentStyle, shouldRender: false)
    }

    private mutating func update(
        style: UIUserInterfaceStyle,
        shouldRender: Bool
    ) -> AppearanceTransitionUpdate {
        let shouldAnnounce = isVisible && isActive && lastCommunicatedStyle != style
        if shouldAnnounce {
            lastCommunicatedStyle = style
        }
        return AppearanceTransitionUpdate(
            style: style,
            shouldRender: shouldRender,
            shouldAnnounce: shouldAnnounce
        )
    }
}

@MainActor
final class ViewController: UIViewController {

    private let appearanceLabel = UILabel()
    private var appearanceState = AppearanceTransitionState()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "appearance-state-root-view"
        configureAppearanceLabel()
        apply(appearanceState.load(style: traitCollection.userInterfaceStyle))
        configureAppearanceObservation()
        configureActivityObservation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apply(appearanceState.setVisible(true))
        apply(appearanceState.setActive(UIApplication.shared.applicationState == .active))
    }

    override func viewWillDisappear(_ animated: Bool) {
        apply(appearanceState.setVisible(false))
        super.viewWillDisappear(animated)
    }

    private func configureAppearanceObservation() {
        if #available(tvOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
                (controller: ViewController, _: UITraitCollection) in
                controller.handleAppearanceTransition()
            }
        }
    }

    private func configureActivityObservation() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(tvOS 17.0, *) {
            return
        }

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        handleAppearanceTransition()
    }

    private func handleAppearanceTransition() {
        guard isViewLoaded else {
            return
        }

        apply(appearanceState.transition(to: traitCollection.userInterfaceStyle))
    }

    @objc private func applicationDidBecomeActive() {
        apply(appearanceState.setActive(true))
    }

    @objc private func applicationWillResignActive() {
        apply(appearanceState.setActive(false))
    }

    private func configureAppearanceLabel() {
        appearanceLabel.translatesAutoresizingMaskIntoConstraints = false
        appearanceLabel.textAlignment = .center
        appearanceLabel.numberOfLines = 0
        appearanceLabel.lineBreakMode = .byWordWrapping
        appearanceLabel.adjustsFontSizeToFitWidth = true
        appearanceLabel.minimumScaleFactor = 0.6
        appearanceLabel.accessibilityIdentifier = "appearance-state-label"
        appearanceLabel.isAccessibilityElement = true
        appearanceLabel.isUserInteractionEnabled = false
        appearanceLabel.accessibilityTraits = .staticText
        appearanceLabel.accessibilityHint = "Shows the current tvOS appearance mode"
        appearanceLabel.font = UIFont.boldSystemFont(ofSize: 54.0)
        view.addSubview(appearanceLabel)

        NSLayoutConstraint.activate([
            appearanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appearanceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appearanceLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            appearanceLabel.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8)
        ])
    }

    private func apply(_ update: AppearanceTransitionUpdate?) {
        guard let update = update else {
            return
        }

        let presentation = AppearancePresentation.resolve(for: update.style)
        if update.shouldRender {
            setAppearance(
                text: presentation.text,
                backgroundColor: presentation.backgroundColor,
                textColor: presentation.textColor
            )
        }
        if update.shouldAnnounce {
            UIAccessibility.post(notification: .announcement, argument: presentation.text)
        }
    }

    private func setAppearance(text: String, backgroundColor: UIColor, textColor: UIColor) {
        appearanceLabel.text = text
        appearanceLabel.accessibilityLabel = text
        appearanceLabel.textColor = textColor
        view.backgroundColor = backgroundColor
    }
}
