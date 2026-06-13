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

    static func shouldAnnounceChange(
        from previousStyle: UIUserInterfaceStyle?,
        to currentStyle: UIUserInterfaceStyle
    ) -> Bool {
        guard let previousStyle = previousStyle else {
            return false
        }
        return previousStyle != currentStyle
    }
}

final class ViewController: UIViewController {

    private let appearanceLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "appearance-state-root-view"
        configureAppearanceLabel()
        updateAppearance(for: traitCollection)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard AppearancePresentation.shouldAnnounceChange(
            from: previousTraitCollection?.userInterfaceStyle,
            to: traitCollection.userInterfaceStyle
        ) else {
            return
        }

        updateAppearance(for: traitCollection)
        UIAccessibility.post(notification: .announcement,
                             argument: appearanceLabel.accessibilityLabel)
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

    private func updateAppearance(for traitCollection: UITraitCollection) {
        let presentation = AppearancePresentation.resolve(
            for: traitCollection.userInterfaceStyle
        )
        setAppearance(
            text: presentation.text,
            backgroundColor: presentation.backgroundColor,
            textColor: presentation.textColor
        )
    }

    private func setAppearance(text: String, backgroundColor: UIColor, textColor: UIColor) {
        appearanceLabel.text = text
        appearanceLabel.accessibilityLabel = text
        appearanceLabel.textColor = textColor
        view.backgroundColor = backgroundColor
    }
}
