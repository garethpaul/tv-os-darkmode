//
//  ViewController.swift
//  tvos-darkmode

import UIKit

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

        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }

        updateAppearance(for: traitCollection)
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
        switch traitCollection.userInterfaceStyle {
        case .dark:
            setAppearance(text: "Dark Mode",
                          backgroundColor: UIColor.black,
                          textColor: UIColor.white)
        case .light:
            setAppearance(text: "Light Mode",
                          backgroundColor: UIColor.white,
                          textColor: UIColor.black)
        default:
            setAppearance(text: "Automatic Mode",
                          backgroundColor: UIColor.darkGray,
                          textColor: UIColor.white)
        }
    }

    private func setAppearance(text: String, backgroundColor: UIColor, textColor: UIColor) {
        appearanceLabel.text = text
        appearanceLabel.accessibilityLabel = text
        appearanceLabel.textColor = textColor
        view.backgroundColor = backgroundColor
    }
}
