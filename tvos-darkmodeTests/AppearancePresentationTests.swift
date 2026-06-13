import UIKit
import XCTest
@testable import tvos_darkmode

final class AppearancePresentationTests: XCTestCase {
    func testDarkAppearanceUsesWhiteTextOnBlack() {
        let presentation = AppearancePresentation.resolve(for: .dark)

        XCTAssertEqual(presentation.text, "Dark Mode")
        XCTAssertEqual(presentation.backgroundColor, .black)
        XCTAssertEqual(presentation.textColor, .white)
    }

    func testLightAppearanceUsesBlackTextOnWhite() {
        let presentation = AppearancePresentation.resolve(for: .light)

        XCTAssertEqual(presentation.text, "Light Mode")
        XCTAssertEqual(presentation.backgroundColor, .white)
        XCTAssertEqual(presentation.textColor, .black)
    }

    func testUnspecifiedAppearanceUsesAutomaticFallback() {
        let presentation = AppearancePresentation.resolve(for: .unspecified)

        XCTAssertEqual(presentation.text, "Automatic Mode")
        XCTAssertEqual(presentation.backgroundColor, .darkGray)
        XCTAssertEqual(presentation.textColor, .white)
    }

    func testMissingPreviousStyleDoesNotAnnounce() {
        XCTAssertFalse(
            AppearancePresentation.shouldAnnounceChange(from: nil, to: .dark)
        )
    }

    func testUnchangedStyleDoesNotAnnounce() {
        XCTAssertFalse(
            AppearancePresentation.shouldAnnounceChange(from: .dark, to: .dark)
        )
    }

    func testLightToDarkStyleChangeAnnounces() {
        XCTAssertTrue(
            AppearancePresentation.shouldAnnounceChange(from: .light, to: .dark)
        )
    }

    func testDarkToLightStyleChangeAnnounces() {
        XCTAssertTrue(
            AppearancePresentation.shouldAnnounceChange(from: .dark, to: .light)
        )
    }

    func testDarkControllerRendersAppearanceHierarchy() {
        assertController(
            style: .dark,
            text: "Dark Mode",
            backgroundColor: .black,
            textColor: .white
        )
    }

    func testLightControllerRendersAppearanceHierarchy() {
        assertController(
            style: .light,
            text: "Light Mode",
            backgroundColor: .white,
            textColor: .black
        )
    }

    private func assertController(
        style: UIUserInterfaceStyle,
        text: String,
        backgroundColor: UIColor,
        textColor: UIColor
    ) {
        let container = UIViewController()
        let controller = ViewController()
        container.addChild(controller)
        container.setOverrideTraitCollection(
            UITraitCollection(userInterfaceStyle: style),
            forChild: controller
        )
        controller.loadViewIfNeeded()

        XCTAssertEqual(controller.traitCollection.userInterfaceStyle, style)
        XCTAssertEqual(controller.view.accessibilityIdentifier, "appearance-state-root-view")
        let label = controller.view.subviews
            .compactMap { $0 as? UILabel }
            .first { $0.accessibilityIdentifier == "appearance-state-label" }

        XCTAssertNotNil(label)
        XCTAssertEqual(label?.text, text)
        XCTAssertEqual(label?.accessibilityLabel, text)
        XCTAssertEqual(label?.textColor, textColor)
        XCTAssertEqual(controller.view.backgroundColor, backgroundColor)
    }
}
