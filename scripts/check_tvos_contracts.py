#!/usr/bin/env python3
"""Static verification for the tvOS dark mode sample."""

from pathlib import Path
import json
import plistlib
import re
import sys
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
DOCS_PLANS = ROOT / "docs" / "plans"
CANONICAL_PLAN = DOCS_PLANS / "2026-06-08-tvos-darkmode-baseline.md"


def fail(message):
    print(f"check_tvos_contracts.py: {message}", file=sys.stderr)
    return 1


def read_text(relative_path):
    return (ROOT / relative_path).read_text(encoding="utf-8")


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def check_docs_plans():
    require(CANONICAL_PLAN.exists(), "docs/plans/2026-06-08-tvos-darkmode-baseline.md is missing")
    plans = sorted(DOCS_PLANS.glob("*.md")) if DOCS_PLANS.exists() else []
    require(plans, "docs/plans must contain at least one completed plan")
    for plan_path in plans:
        plan = plan_path.read_text(encoding="utf-8")
        require(
            "Status: Completed" in plan and "make check" in plan,
            f"{plan_path.relative_to(ROOT)} must record completed status and make check verification",
        )


def check_project_files_parse():
    with (ROOT / "tvos-darkmode/Info.plist").open("rb") as plist_file:
        info = plistlib.load(plist_file)
    require(info["UIMainStoryboardFile"] == "Main", "Info.plist must launch Main.storyboard")
    require(info["UIUserInterfaceStyle"] == "Automatic", "app must opt into automatic appearance")

    ET.parse(ROOT / "tvos-darkmode/Base.lproj/Main.storyboard")

    for path in (ROOT / "tvos-darkmode/Assets.xcassets").rglob("Contents.json"):
        json.loads(path.read_text(encoding="utf-8"))


def check_xcode_project_contracts():
    project = read_text("tvos-darkmode.xcodeproj/project.pbxproj")
    require("SDKROOT = appletvos;" in project, "project must target the tvOS SDK")
    require("TARGETED_DEVICE_FAMILY = 3;" in project, "project must remain tvOS-only")
    require("SWIFT_VERSION = 3.0;" in project, "legacy Swift version must stay explicit")
    require("ViewController.swift in Sources" in project, "ViewController must remain compiled")


def check_visible_appearance_state():
    view_controller = read_text("tvos-darkmode/ViewController.swift")

    require(
        "private let appearanceLabel = UILabel()" in view_controller,
        "ViewController must own a visible appearance label",
    )
    require(
        "configureAppearanceLabel()" in view_controller,
        "ViewController must configure the appearance label on load",
    )
    require(
        "appearanceLabel.numberOfLines = 0" in view_controller,
        "appearance label must wrap instead of truncating longer states",
    )
    require(
        "appearanceLabel.lineBreakMode = .byWordWrapping" in view_controller,
        "appearance label must wrap on word boundaries",
    )
    require(
        'appearanceLabel.accessibilityIdentifier = "appearance-state-label"' in view_controller,
        "appearance label must have a stable accessibility identifier",
    )
    require(
        "appearanceLabel.isAccessibilityElement = true" in view_controller,
        "appearance label must be exposed as an accessibility element",
    )
    require(
        view_controller.count("updateAppearance(for: traitCollection)") >= 2,
        "appearance state must be applied on load and after trait changes",
    )
    require(
        "traitCollection.responds(to:" in view_controller,
        "runtime userInterfaceStyle availability guard must be preserved",
    )
    require(
        all(fragment in view_controller for fragment in ["case .dark:", "case .light:", "default:"]),
        "appearance update must handle dark, light, and fallback styles",
    )
    for fragment, description in [
        (
            'setAppearance(text: "Dark Mode",\n'
            '                          backgroundColor: UIColor.black,\n'
            '                          textColor: UIColor.white)',
            "dark mode must use white text on black",
        ),
        (
            'setAppearance(text: "Light Mode",\n'
            '                          backgroundColor: UIColor.white,\n'
            '                          textColor: UIColor.black)',
            "light mode must use black text on white",
        ),
        (
            'setAppearance(text: "Automatic Mode",\n'
            '                          backgroundColor: UIColor.darkGray,\n'
            '                          textColor: UIColor.white)',
            "fallback mode must use white text on dark gray",
        ),
    ]:
        require(fragment in view_controller, description)
    require(
        re.search(
            r"private func setAppearance\(text: String, backgroundColor: UIColor, textColor: UIColor\).*?"
            r"appearanceLabel\.text = text.*?appearanceLabel\.accessibilityLabel = text.*?"
            r"appearanceLabel\.textColor = textColor.*?view\.backgroundColor = backgroundColor",
            view_controller,
            re.DOTALL,
        ),
        "appearance updates must change label text, accessibility text, text color, and background color",
    )


def check_manual_verification_docs():
    readme = read_text("README.md")
    for fragment in [
        "### Manual Appearance Verification",
        "Light appearance",
        "`Light Mode`",
        "Dark appearance",
        "`Dark Mode`",
        "`Appearance Unavailable`",
        "docs/plans/2026-06-08-manual-appearance-verification.md",
    ]:
        require(fragment in readme, f"README manual verification is missing: {fragment}")


def main():
    checks = [
        check_docs_plans,
        check_project_files_parse,
        check_xcode_project_contracts,
        check_visible_appearance_state,
        check_manual_verification_docs,
    ]
    try:
        for check in checks:
            check()
    except (AssertionError, ET.ParseError, json.JSONDecodeError, plistlib.InvalidFileException) as exc:
        return fail(str(exc))

    print(f"tvOS static contracts passed ({len(checks)} checks).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
