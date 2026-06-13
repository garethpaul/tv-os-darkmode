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
}
