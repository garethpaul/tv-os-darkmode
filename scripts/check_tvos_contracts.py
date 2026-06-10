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
ROOT_IDENTIFIER_PLAN = DOCS_PLANS / "2026-06-09-root-view-identifier.md"
APP_DELEGATE_LAUNCH_PLAN = DOCS_PLANS / "2026-06-09-app-delegate-launch-options.md"
CI_PLAN = DOCS_PLANS / "2026-06-10-ci-baseline.md"
MODERN_XCODE_PLAN = DOCS_PLANS / "2026-06-10-modern-xcode-build.md"
CI_WORKFLOW = ROOT / ".github" / "workflows" / "check.yml"


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
    require(ROOT_IDENTIFIER_PLAN.exists(), "docs/plans/2026-06-09-root-view-identifier.md is missing")
    require(APP_DELEGATE_LAUNCH_PLAN.exists(), "docs/plans/2026-06-09-app-delegate-launch-options.md is missing")
    require(CI_PLAN.exists(), "docs/plans/2026-06-10-ci-baseline.md is missing")
    require(MODERN_XCODE_PLAN.exists(), "docs/plans/2026-06-10-modern-xcode-build.md is missing")
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
    require(project.count("SWIFT_VERSION = 5.0;") == 2, "both target configurations must use Swift 5")
    require(
        project.count("TVOS_DEPLOYMENT_TARGET = 12.0;") == 2,
        "both project configurations must target tvOS 12 or newer",
    )
    require("LastSwiftMigration = 1640;" in project, "project must record the Xcode 16.4 migration")
    require("ViewController.swift in Sources" in project, "ViewController must remain compiled")


def check_app_delegate_contracts():
    app_delegate = read_text("tvos-darkmode/AppDelegate.swift")
    require(
        "@main" in app_delegate and "final class AppDelegate" in app_delegate,
        "AppDelegate must use the modern Swift application entry point",
    )
    require(
        "[UIApplication.LaunchOptionsKey: Any]?" in app_delegate,
        "AppDelegate launch callback must use the modern UIKit launch-options type",
    )
    require(
        "UIApplicationLaunchOptionsKey" not in app_delegate and "@UIApplicationMain" not in app_delegate,
        "AppDelegate must not use removed Swift 3 application APIs",
    )


def check_visible_appearance_state():
    view_controller = read_text("tvos-darkmode/ViewController.swift")

    require(
        "private let appearanceLabel = UILabel()" in view_controller,
        "ViewController must own a visible appearance label",
    )
    require("final class ViewController" in view_controller, "ViewController must remain non-subclassable")
    require(
        'view.accessibilityIdentifier = "appearance-state-root-view"' in view_controller,
        "root appearance view must have a stable accessibility identifier",
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
        "appearanceLabel.adjustsFontSizeToFitWidth = true" in view_controller,
        "appearance label must scale down before overflowing the viewport",
    )
    require(
        "appearanceLabel.minimumScaleFactor = 0.6" in view_controller,
        "appearance label must keep a readable minimum scale factor",
    )
    require(
        "appearanceLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)" in view_controller,
        "appearance label must stay within the viewport width",
    )
    require(
        "appearanceLabel.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8)" in view_controller,
        "appearance label must stay within the viewport height",
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
        "appearanceLabel.isUserInteractionEnabled = false" in view_controller,
        "appearance label must remain a display-only, non-interactive view",
    )
    require(
        "appearanceLabel.accessibilityTraits = .staticText" in view_controller,
        "appearance label must identify itself as static text for assistive technologies",
    )
    require(
        'appearanceLabel.accessibilityHint = "Shows the current tvOS appearance mode"' in view_controller,
        "appearance label must describe its appearance-state purpose to assistive technologies",
    )
    require(
        view_controller.count("updateAppearance(for: traitCollection)") >= 2,
        "appearance state must be applied on load and after trait changes",
    )
    require(
        "traitCollection.responds(to:" not in view_controller,
        "tvOS 12 appearance handling must not rely on Objective-C selector checks",
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
        "`Automatic Mode`",
        "docs/plans/2026-06-08-manual-appearance-verification.md",
    ]:
        require(fragment in readme, f"README manual verification is missing: {fragment}")


def check_ci_baseline_docs():
    require(CI_WORKFLOW.exists(), ".github/workflows/check.yml is missing")
    workflow = CI_WORKFLOW.read_text(encoding="utf-8")
    for contract in (
        "branches:\n      - master",
        "pull_request:",
        "workflow_dispatch:",
        "permissions:\n  contents: read",
        "group: check-${{ github.workflow }}-${{ github.ref }}",
        "cancel-in-progress: true",
        "runs-on: ubuntu-24.04",
        "runs-on: macos-15",
        "timeout-minutes: 5",
        "timeout-minutes: 15",
        "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3",
        "actions/setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405 # v6.2.0",
        'python-version: "3.12"',
        "run: make check",
        "DEVELOPER_DIR: /Applications/Xcode_16.4.app/Contents/Developer",
        "run: make build",
    ):
        require(contract in workflow, f"CI workflow must include {contract!r}")
    require(workflow.count("runs-on: ubuntu-24.04") == 1, "CI must have one fixed Ubuntu job")
    require(workflow.count("runs-on: macos-15") == 1, "CI must have one fixed macOS build job")
    require(
        workflow.count("actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3") == 2,
        "both CI jobs must use the annotated checkout pin",
    )
    require("ubuntu-latest" not in workflow and "macos-latest" not in workflow, "CI runners must not float")
    require("@v" not in workflow, "CI workflow actions must use immutable commits")
    makefile = read_text("Makefile")
    for contract in (
        "ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))",
        '$(PYTHON) "$(ROOT)/scripts/check_tvos_contracts.py"',
        'cd "$(ROOT)" && xcodebuild',
    ):
        require(contract in makefile, f"Makefile must support invocation outside the repository: {contract}")
    for docs_file in ("README.md", "VISION.md", "SECURITY.md", "CHANGES.md"):
        require("GitHub Actions" in read_text(docs_file), f"{docs_file} must document the GitHub Actions baseline")


def main():
    checks = [
        check_docs_plans,
        check_project_files_parse,
        check_xcode_project_contracts,
        check_app_delegate_contracts,
        check_visible_appearance_state,
        check_manual_verification_docs,
        check_ci_baseline_docs,
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
