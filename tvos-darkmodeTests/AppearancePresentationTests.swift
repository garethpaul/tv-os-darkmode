import UIKit
import XCTest
@testable import tvos_darkmode

@MainActor
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

    func testInitialAppearanceRendersWithoutAnnouncement() {
        var state = AppearanceTransitionState()

        XCTAssertEqual(
            state.load(style: .dark),
            AppearanceTransitionUpdate(style: .dark, shouldRender: true, shouldAnnounce: false)
        )
    }

    func testVisibleActiveTransitionRendersAndAnnouncesOnce() {
        var state = AppearanceTransitionState()
        _ = state.load(style: .dark)
        XCTAssertNil(state.setVisible(true))
        XCTAssertNil(state.setActive(true))

        XCTAssertEqual(
            state.transition(to: .light),
            AppearanceTransitionUpdate(style: .light, shouldRender: true, shouldAnnounce: true)
        )
        XCTAssertNil(state.transition(to: .light))
    }

    func testInactiveTransitionDefersAnnouncementUntilReactivation() {
        var state = AppearanceTransitionState()
        _ = state.load(style: .dark)
        _ = state.setVisible(true)
        _ = state.setActive(true)
        _ = state.setActive(false)

        XCTAssertEqual(
            state.transition(to: .light),
            AppearanceTransitionUpdate(style: .light, shouldRender: true, shouldAnnounce: false)
        )
        XCTAssertEqual(
            state.setActive(true),
            AppearanceTransitionUpdate(style: .light, shouldRender: false, shouldAnnounce: true)
        )
        XCTAssertNil(state.setActive(true))
    }

    func testHiddenTransitionDefersAnnouncementUntilVisible() {
        var state = AppearanceTransitionState()
        _ = state.load(style: .dark)
        _ = state.setActive(true)

        XCTAssertEqual(
            state.transition(to: .light),
            AppearanceTransitionUpdate(style: .light, shouldRender: true, shouldAnnounce: false)
        )
        XCTAssertEqual(
            state.setVisible(true),
            AppearanceTransitionUpdate(style: .light, shouldRender: false, shouldAnnounce: true)
        )
        XCTAssertNil(state.setVisible(true))
    }

    func testInactiveRoundTripBackToPresentedStyleDoesNotAnnounce() {
        var state = AppearanceTransitionState()
        _ = state.load(style: .dark)
        _ = state.setVisible(true)
        _ = state.setActive(true)
        _ = state.setActive(false)
        _ = state.transition(to: .light)
        _ = state.transition(to: .dark)

        XCTAssertNil(state.setActive(true))
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

    func testDarkControllerRendersLightAppearanceAfterTraitChange() {
        assertControllerTransition(
            from: .dark,
            to: .light,
            text: "Light Mode",
            backgroundColor: .white,
            textColor: .black
        )
    }

    func testLightControllerRendersDarkAppearanceAfterTraitChange() {
        assertControllerTransition(
            from: .light,
            to: .dark,
            text: "Dark Mode",
            backgroundColor: .black,
            textColor: .white
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

        assertControllerAppearance(
            controller,
            style: style,
            text: text,
            backgroundColor: backgroundColor,
            textColor: textColor
        )
    }

    private func assertControllerTransition(
        from initialStyle: UIUserInterfaceStyle,
        to currentStyle: UIUserInterfaceStyle,
        text: String,
        backgroundColor: UIColor,
        textColor: UIColor
    ) {
        let container = UIViewController()
        let controller = ViewController()
        container.addChild(controller)
        container.setOverrideTraitCollection(
            UITraitCollection(userInterfaceStyle: initialStyle),
            forChild: controller
        )
        controller.loadViewIfNeeded()

        let initialPresentation = AppearancePresentation.resolve(for: initialStyle)
        assertControllerAppearance(
            controller,
            style: initialStyle,
            text: initialPresentation.text,
            backgroundColor: initialPresentation.backgroundColor,
            textColor: initialPresentation.textColor
        )

        container.setOverrideTraitCollection(
            UITraitCollection(userInterfaceStyle: currentStyle),
            forChild: controller
        )

        assertControllerAppearance(
            controller,
            style: currentStyle,
            text: text,
            backgroundColor: backgroundColor,
            textColor: textColor
        )
    }

    private func assertControllerAppearance(
        _ controller: ViewController,
        style: UIUserInterfaceStyle,
        text: String,
        backgroundColor: UIColor,
        textColor: UIColor
    ) {
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
