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
EXECUTABLE_TEST_PLAN = DOCS_PLANS / "2026-06-12-executable-appearance-tests.md"
CODEQL_PLAN = DOCS_PLANS / "2026-06-12-codeql-manual-swift-build.md"
INITIAL_ANNOUNCEMENT_PLAN = DOCS_PLANS / "2026-06-13-initial-appearance-announcement.md"
TRAIT_TRANSITION_PLAN = DOCS_PLANS / "2026-06-13-controller-trait-transition-rendering.md"
ROOT_OVERRIDE_PLAN = DOCS_PLANS / "2026-06-14-make-root-override-protection.md"
MAKE_AUTHORITY_PLAN = DOCS_PLANS / "2026-06-21-make-authority-hardening.md"
MODERN_TRAIT_OBSERVATION_PLAN = DOCS_PLANS / "2026-06-16-modern-trait-observation.md"
DEEP_REVIEW_PLAN = DOCS_PLANS / "2026-06-19-tvos-lifecycle-deep-review.md"
CI_WORKFLOW = ROOT / ".github" / "workflows" / "check.yml"
CODEQL_WORKFLOW = ROOT / ".github" / "workflows" / "codeql.yml"
MAKE_WRAPPER = ROOT / "scripts" / "run-make.sh"
SHARED_SCHEME = ROOT / "tvos-darkmode.xcodeproj" / "xcshareddata" / "xcschemes" / "tvos-darkmode.xcscheme"
EXPECTED_WORKFLOW = """name: Check

on:
  push:
    branches:
      - master
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: check-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  static-contracts:
    runs-on: ubuntu-24.04
    timeout-minutes: 5
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false
      - name: Set up Python
        uses: actions/setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405 # v6.2.0
        with:
          python-version: "3.12"
      - name: Run baseline
        run: ./scripts/run-make.sh check

  xcode-test:
    runs-on: macos-15
    timeout-minutes: 15
    env:
      DEVELOPER_DIR: /Applications/Xcode_16.4.app/Contents/Developer
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false
      - name: Run tvOS XCTest
        run: ./scripts/run-make.sh test
"""
EXPECTED_MAKE_WRAPPER = """#!/bin/sh
set -eu

case $0 in
  /*) script_path=$0 ;;
  *) script_path=$(/bin/pwd -P)/$0 ;;
esac

link_count=0
while [ -L "$script_path" ]; do
  link_count=$((link_count + 1))
  if [ "$link_count" -gt 40 ]; then
    echo "repository verification entrypoint has too many symbolic links" >&2
    exit 66
  fi

  if ! link_target_with_sentinel=$(/usr/bin/readlink -n "$script_path" && printf x); then
    echo "repository verification entrypoint could not read symbolic link" >&2
    exit 66
  fi
  link_target=${link_target_with_sentinel%x}
  case $link_target in
    /*) script_path=$link_target ;;
    *) script_path=$(/usr/bin/dirname "$script_path")/$link_target ;;
  esac
done

if [ ! -f "$script_path" ]; then
  echo "repository verification entrypoint did not resolve to a regular file" >&2
  exit 66
fi

SCRIPT_DIR=$(CDPATH='' cd -P "$(/usr/bin/dirname "$script_path")" && /bin/pwd -P)
ROOT_DIR=$(CDPATH='' cd -P "$SCRIPT_DIR/.." && /bin/pwd -P)

if [ "$#" -ne 1 ]; then
  echo "usage: scripts/run-make.sh check|test" >&2
  exit 64
fi

case $1 in
  check|test)
    target=$1
    ;;
  *)
    echo "usage: scripts/run-make.sh check|test" >&2
    exit 64
    ;;
esac

exec /usr/bin/env \\
  -u MAKEFILES \\
  -u MAKEFLAGS \\
  -u MFLAGS \\
  -u MAKEOVERRIDES \\
  -u GNUMAKEFLAGS \\
  /usr/bin/make --no-print-directory -f "$ROOT_DIR/Makefile" "$target"
"""
EXPECTED_CODEQL_WORKFLOW = """name: CodeQL

on:
  push:
    branches:
      - master
  pull_request:
  schedule:
    - cron: "23 4 * * 1"
  workflow_dispatch:

permissions:
  contents: read
  security-events: write

concurrency:
  group: codeql-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  analyze-scripts:
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    strategy:
      fail-fast: false
      matrix:
        language:
          - actions
          - python
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false
      - name: Initialize CodeQL
        uses: github/codeql-action/init@8aad20d150bbac5944a9f9d289da16a4b0d87c1e # v4
        with:
          languages: ${{ matrix.language }}
          build-mode: none
      - name: Analyze
        uses: github/codeql-action/analyze@8aad20d150bbac5944a9f9d289da16a4b0d87c1e # v4

  analyze-swift:
    runs-on: macos-15
    timeout-minutes: 25
    env:
      DEVELOPER_DIR: /Applications/Xcode_16.4.app/Contents/Developer
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false
      - name: Initialize CodeQL
        uses: github/codeql-action/init@8aad20d150bbac5944a9f9d289da16a4b0d87c1e # v4
        with:
          languages: swift
          build-mode: manual
      - name: Build tvOS app for analysis
        run: >-
          xcodebuild
          -project tvos-darkmode.xcodeproj
          -target tvos-darkmode
          -destination "generic/platform=tvOS Simulator"
          -configuration Debug
          ARCHS=arm64
          ONLY_ACTIVE_ARCH=YES
          CODE_SIGNING_ALLOWED=NO
          build
      - name: Analyze
        uses: github/codeql-action/analyze@8aad20d150bbac5944a9f9d289da16a4b0d87c1e # v4
"""


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
    require(
        EXECUTABLE_TEST_PLAN.exists(),
        "docs/plans/2026-06-12-executable-appearance-tests.md is missing",
    )
    require(
        CODEQL_PLAN.exists(),
        "docs/plans/2026-06-12-codeql-manual-swift-build.md is missing",
    )
    require(
        INITIAL_ANNOUNCEMENT_PLAN.exists(),
        "docs/plans/2026-06-13-initial-appearance-announcement.md is missing",
    )
    require(
        TRAIT_TRANSITION_PLAN.exists(),
        "docs/plans/2026-06-13-controller-trait-transition-rendering.md is missing",
    )
    require(
        ROOT_OVERRIDE_PLAN.exists(),
        "docs/plans/2026-06-14-make-root-override-protection.md is missing",
    )
    require(
        MAKE_AUTHORITY_PLAN.exists(),
        "docs/plans/2026-06-21-make-authority-hardening.md is missing",
    )
    require(
        MODERN_TRAIT_OBSERVATION_PLAN.exists(),
        "docs/plans/2026-06-16-modern-trait-observation.md is missing",
    )
    require(
        DEEP_REVIEW_PLAN.exists(),
        "docs/plans/2026-06-19-tvos-lifecycle-deep-review.md is missing",
    )
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
    scene_manifest = info["UIApplicationSceneManifest"]
    require(
        scene_manifest["UIApplicationSupportsMultipleScenes"] is False,
        "the sample must remain single-scene",
    )
    scene_configurations = scene_manifest["UISceneConfigurations"][
        "UIWindowSceneSessionRoleApplication"
    ]
    require(len(scene_configurations) == 1, "the app must define one window-scene configuration")
    require(
        scene_configurations[0]["UISceneDelegateClassName"]
        == "$(PRODUCT_MODULE_NAME).SceneDelegate",
        "the scene manifest must use SceneDelegate",
    )
    require(
        scene_configurations[0]["UISceneStoryboardFile"] == "Main",
        "the scene lifecycle must keep the Main storyboard",
    )

    ET.parse(ROOT / "tvos-darkmode/Base.lproj/Main.storyboard")
    ET.parse(SHARED_SCHEME)

    for path in (ROOT / "tvos-darkmode/Assets.xcassets").rglob("Contents.json"):
        json.loads(path.read_text(encoding="utf-8"))


def check_xcode_project_contracts():
    project = read_text("tvos-darkmode.xcodeproj/project.pbxproj")
    require("SDKROOT = appletvos;" in project, "project must target the tvOS SDK")
    require("TARGETED_DEVICE_FAMILY = 3;" in project, "project must remain tvOS-only")
    require(
        project.count("SWIFT_VERSION = 5.0;") == 4,
        "app and test target configurations must use Swift 5",
    )
    require(
        project.count("TVOS_DEPLOYMENT_TARGET = 12.0;") == 4,
        "app and test configurations must target tvOS 12 or newer",
    )
    require("LastSwiftMigration = 1640;" in project, "project must record the Xcode 16.4 migration")
    require("ViewController.swift in Sources" in project, "ViewController must remain compiled")
    require("SceneDelegate.swift in Sources" in project, "SceneDelegate must remain compiled")
    for fragment in (
        'productType = "com.apple.product-type.bundle.unit-test";',
        "AppearancePresentationTests.swift in Sources",
        'TEST_HOST = "$(BUILT_PRODUCTS_DIR)/tvos-darkmode.app/tvos-darkmode";',
        "A12000000000000000000007 /* tvos-darkmodeTests */",
    ):
        require(fragment in project, f"Xcode test target is missing: {fragment}")

    scheme = SHARED_SCHEME.read_text(encoding="utf-8")
    for fragment in (
        '<TestAction',
        'BlueprintIdentifier = "A12000000000000000000007"',
        'BuildableName = "tvos-darkmodeTests.xctest"',
        'BlueprintName = "tvos-darkmodeTests"',
        'skipped = "NO"',
    ):
        require(fragment in scheme, f"shared XCTest scheme is missing: {fragment}")
    require(
        scheme.count('BlueprintIdentifier = "A12000000000000000000007"') == 2,
        "shared scheme must build and execute the test bundle",
    )


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
    scene_delegate = read_text("tvos-darkmode/SceneDelegate.swift")
    require(
        "@available(tvOS 13.0, *)" in scene_delegate
        and "final class SceneDelegate: UIResponder, UIWindowSceneDelegate" in scene_delegate
        and "var window: UIWindow?" in scene_delegate,
        "SceneDelegate must provide the scene-based lifecycle while preserving tvOS 12 fallback",
    )


def check_visible_appearance_state():
    view_controller = read_text("tvos-darkmode/ViewController.swift")

    require("@MainActor\nfinal class ViewController" in view_controller, "UI ownership must be main-actor isolated")
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
        "UIAccessibility.post(notification: .announcement," in view_controller
        and "argument: presentation.text)" in view_controller,
        "appearance changes must announce the updated state to assistive technologies",
    )
    modern_observation = re.search(
        r"private func configureAppearanceObservation\(\).*?\n    \}",
        view_controller,
        re.DOTALL,
    )
    require(modern_observation is not None, "modern appearance observation must be configured")
    require(
        "if #available(tvOS 17.0, *)" in modern_observation.group(0)
        and "registerForTraitChanges([UITraitUserInterfaceStyle.self])" in modern_observation.group(0)
        and "controller.handleAppearanceTransition()" in modern_observation.group(0),
        "tvOS 17 must register only user-interface-style changes through the shared handler",
    )
    require(
        view_controller.count("registerForTraitChanges(") == 1,
        "appearance observation must have exactly one focused modern registration",
    )
    trait_change = re.search(
        r"override func traitCollectionDidChange.*?\n    \}",
        view_controller,
        re.DOTALL,
    )
    require(trait_change is not None, "traitCollectionDidChange must remain implemented")
    require(
        "if #available(tvOS 17.0, *)" in trait_change.group(0)
        and "return" in trait_change.group(0)
        and "handleAppearanceTransition()" in trait_change.group(0),
        "legacy trait changes must run only below tvOS 17 through the shared handler",
    )
    require(
        "struct AppearanceTransitionState" in view_controller
        and "lastCommunicatedStyle" in view_controller
        and "isVisible && isActive" in view_controller
        and "appearanceState.transition(to: traitCollection.userInterfaceStyle)" in view_controller,
        "appearance transitions must deduplicate and gate announcements by visibility and activity",
    )
    require(
        "UIApplication.didBecomeActiveNotification" in view_controller
        and "UIApplication.willResignActiveNotification" in view_controller
        and "appearanceState.setVisible(true)" in view_controller
        and "appearanceState.setVisible(false)" in view_controller
        and "appearanceState.setActive(true)" in view_controller
        and "appearanceState.setActive(false)" in view_controller,
        "controller lifecycle must gate announcements across visibility and app activity",
    )
    require(
        "if update.shouldRender" in view_controller
        and "if update.shouldAnnounce" in view_controller
        and view_controller.index("if update.shouldRender") < view_controller.index("if update.shouldAnnounce"),
        "appearance rendering must occur before any announcement",
    )
    require(
        "traitCollection.responds(to:" not in view_controller,
        "tvOS 12 appearance handling must not rely on Objective-C selector checks",
    )
    require("struct AppearancePresentation" in view_controller, "appearance mapping must be testable")
    require(
        all(fragment in view_controller for fragment in ["case .dark:", "case .light:", "default:"]),
        "appearance mapping must handle dark, light, and fallback styles",
    )
    for fragment, description in [
        (
            'text: "Dark Mode",\n'
            '                backgroundColor: .black,\n'
            '                textColor: .white',
            "dark mode must use white text on black",
        ),
        (
            'text: "Light Mode",\n'
            '                backgroundColor: .white,\n'
            '                textColor: .black',
            "light mode must use black text on white",
        ),
        (
            'text: "Automatic Mode",\n'
            '                backgroundColor: .darkGray,\n'
            '                textColor: .white',
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
    require(
        "AppearancePresentation.resolve(" in view_controller
        and "text: presentation.text" in view_controller
        and "backgroundColor: presentation.backgroundColor" in view_controller
        and "textColor: presentation.textColor" in view_controller,
        "ViewController must apply the tested appearance presentation",
    )


def check_executable_tests():
    tests = read_text("tvos-darkmodeTests/AppearancePresentationTests.swift")
    for fragment in (
        "import XCTest",
        "@testable import tvos_darkmode",
        "testDarkAppearanceUsesWhiteTextOnBlack",
        "testLightAppearanceUsesBlackTextOnWhite",
        "testUnspecifiedAppearanceUsesAutomaticFallback",
        "testInitialAppearanceRendersWithoutAnnouncement",
        "testVisibleActiveTransitionRendersAndAnnouncesOnce",
        "testInactiveTransitionDefersAnnouncementUntilReactivation",
        "testHiddenTransitionDefersAnnouncementUntilVisible",
        "testInactiveRoundTripBackToPresentedStyleDoesNotAnnounce",
        "testDarkControllerRendersAppearanceHierarchy",
        "testLightControllerRendersAppearanceHierarchy",
        "testDarkControllerRendersLightAppearanceAfterTraitChange",
        "testLightControllerRendersDarkAppearanceAfterTraitChange",
        'XCTAssertEqual(presentation.text, "Dark Mode")',
        'XCTAssertEqual(presentation.text, "Light Mode")',
        'XCTAssertEqual(presentation.text, "Automatic Mode")',
        "container.addChild(controller)",
        "container.setOverrideTraitCollection(",
        "UITraitCollection(userInterfaceStyle: style)",
        "controller.loadViewIfNeeded()",
        "UITraitCollection(userInterfaceStyle: initialStyle)",
        "UITraitCollection(userInterfaceStyle: currentStyle)",
        "let initialPresentation = AppearancePresentation.resolve(for: initialStyle)",
        "style: initialStyle",
        "text: initialPresentation.text",
        "backgroundColor: initialPresentation.backgroundColor",
        "textColor: initialPresentation.textColor",
        "style: currentStyle",
        "XCTAssertEqual(controller.traitCollection.userInterfaceStyle, style)",
        'XCTAssertEqual(controller.view.accessibilityIdentifier, "appearance-state-root-view")',
        ".compactMap { $0 as? UILabel }",
        '.first { $0.accessibilityIdentifier == "appearance-state-label" }',
        "XCTAssertEqual(label?.text, text)",
        "XCTAssertEqual(label?.accessibilityLabel, text)",
        "XCTAssertEqual(label?.textColor, textColor)",
        "XCTAssertEqual(controller.view.backgroundColor, backgroundColor)",
        "AppearanceTransitionState()",
        "shouldRender: true, shouldAnnounce: false",
        "shouldRender: true, shouldAnnounce: true",
        "shouldRender: false, shouldAnnounce: true",
    ):
        require(fragment in tests, f"XCTest coverage is missing: {fragment}")
    for test_name, initial_style, current_style in (
        ("testDarkControllerRendersLightAppearanceAfterTraitChange", "dark", "light"),
        ("testLightControllerRendersDarkAppearanceAfterTraitChange", "light", "dark"),
    ):
        require(
            re.search(
                rf"func {test_name}\(\).*?assertControllerTransition\(\s*"
                rf"from: \.{initial_style},\s*to: \.{current_style},",
                tests,
                re.DOTALL,
            ),
            f"{test_name} must preserve its {initial_style}-to-{current_style} transition",
        )
    require("XCTFail" not in tests, "XCTest coverage must not contain placeholder failures")
    for path, fragment in (
        ("README.md", "bidirectional trait-transition rendering tests"),
        ("VISION.md", "dark-to-light and light-to-dark rendering covered"),
        ("CHANGES.md", "controller-level coverage for dark-to-light and light-to-dark"),
    ):
        require(fragment in read_text(path), f"{path} must document controller trait-transition coverage")
    for path, fragment in (
        ("README.md", "focused trait registration on tvOS 17"),
        ("VISION.md", "focused tvOS 17 trait registration"),
        ("CHANGES.md", "focused tvOS 17 trait registration"),
    ):
        require(fragment in read_text(path), f"{path} must document modern trait observation")
    require(
        "docs/plans/2026-06-16-modern-trait-observation.md" in read_text("README.md"),
        "README.md must index modern trait observation evidence",
    )
    require(
        "wiring behavior to `traitCollectionDidChange`" not in read_text("VISION.md"),
        "VISION.md must not describe the legacy callback as the sole observation path",
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
    require(CODEQL_WORKFLOW.exists(), ".github/workflows/codeql.yml is missing")
    require(MAKE_WRAPPER.exists(), "scripts/run-make.sh is missing")
    workflow = CI_WORKFLOW.read_text(encoding="utf-8")
    codeql_workflow = CODEQL_WORKFLOW.read_text(encoding="utf-8")
    make_wrapper = MAKE_WRAPPER.read_text(encoding="utf-8")
    require(
        workflow == EXPECTED_WORKFLOW,
        "CI workflow must match the exact credential-free static and Xcode build contract",
    )
    require(
        codeql_workflow == EXPECTED_CODEQL_WORKFLOW,
        "CodeQL workflow must match the exact pinned script and manual Swift build contract",
    )
    require(
        make_wrapper == EXPECTED_MAKE_WRAPPER,
        "trusted Make wrapper must match the exact fixed-target sanitized contract",
    )
    require(
        MAKE_WRAPPER.stat().st_mode & 0o111,
        "trusted Make wrapper must be executable",
    )
    makefile = read_text("Makefile")
    selector = read_text("scripts/select_tvos_destination.py")
    selector_tests = read_text("tests/test_select_tvos_destination.py")
    root_declaration = "override ROOT := $(REPOSITORY_ROOT)"
    root_assignments = re.findall(
        r"^(?:override\s+)?ROOT\s*[:+?]?=", makefile, re.MULTILINE
    )
    require(
        len(root_assignments) == 1
        and makefile.splitlines().count(root_declaration) == 1
        and makefile.splitlines().count("$(PUBLIC_TARGETS): override ROOT := $(REPOSITORY_ROOT)") == 1,
        "Makefile must contain the global and public-target protected repository-root declarations",
    )
    require(
        makefile.count("override REPOSITORY_MAKEFILE := $(lastword $(MAKEFILE_LIST))") == 1
        and makefile.count("override REPOSITORY_ROOT := $(abspath $(dir $(REPOSITORY_MAKEFILE)))") == 1,
        "Makefile must capture its own path before protecting the repository root",
    )
    for contract in (
        ".PHONY: __repository-make-authority build check lint root-test test verify",
        "override PYTHON := $(value PYTHON)",
        "PYTHON must be a literal executable path, not Make syntax",
        "override SHELL := /bin/sh",
        "MAKEFLAGS must not be overridden for repository verification",
        "MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone",
        "MAKEFILE_LIST must not be overridden",
        "$(PUBLIC_TARGETS): override ROOT := $(REPOSITORY_ROOT)",
        "root-test:",
        '"$$ROOT/scripts/test-makefile-authority.sh"',
        "test: lint",
        "verify: root-test lint test build",
        "check: verify",
        '"$$PYTHON" "$$ROOT/scripts/check_tvos_contracts.py"',
        "TVOS_DESTINATION ?=",
        "DERIVED_DATA_PATH ?= $(ROOT)/.build/DerivedData",
        "scripts/select_tvos_destination.py",
        '"$$PYTHON" -m unittest discover',
        'cd "$$ROOT" && xcodebuild',
        '-destination "generic/platform=tvOS Simulator"',
        '-destination "$$destination"',
        '-derivedDataPath "$(DERIVED_DATA_PATH)"',
        "CODE_SIGNING_ALLOWED=NO",
        "CODE_SIGNING_ALLOWED=NO test",
    ):
        require(contract in makefile, f"Makefile must support invocation outside the repository: {contract}")
    for fragment in (
        'DEVICE_NAME = "Apple TV 4K (3rd generation)"',
        '["xcrun", "simctl", "list", "--json"]',
        '["xcrun", "simctl", "create", name, device_type, runtime]',
        "def normalize_udid(value):",
        'raise RuntimeError("simctl list response must be an object")',
        'udid = normalize_udid(device.get("udid"))',
        'raise RuntimeError("created simulator returned no UDID")',
        'return f"platform=tvOS Simulator,id={udid}"',
        'raise RuntimeError("no available tvOS simulator runtime is installed")',
    ):
        require(fragment in selector, f"simulator selector is missing: {fragment}")
    root_guard = 'if not isinstance(payload, dict):'
    require(
        selector.index(root_guard) < selector.index('payload.get("runtimes", [])'),
        "simulator selector must validate the decoded root before payload access",
    )
    for test_name in (
        "test_rejects_non_object_simctl_root",
        "test_uses_matching_device_from_newest_available_runtime",
        "test_creates_matching_device_when_runtime_has_no_device",
        "test_ignores_matching_device_with_blank_udid_and_creates_replacement",
        "test_ignores_matching_device_with_non_string_udid",
        "test_rejects_invalid_created_device_udid",
        "test_rejects_missing_available_tvos_runtime",
    ):
        require(test_name in selector_tests, f"simulator selector test is missing: {test_name}")
    require(
        'for payload in (None, [], "devices", 0, False):' in selector_tests,
        "simulator selector root-shape test must preserve every JSON root fixture",
    )
    for docs_file in ("AGENTS.md", "README.md", "VISION.md", "SECURITY.md", "CHANGES.md"):
        require(
            "Non-object `simctl list --json` roots" in read_text(docs_file),
            f"{docs_file} must document simctl root-shape validation",
        )
    require(
        "docs/plans/2026-06-14-make-root-override-protection.md" in read_text("README.md"),
        "README.md must index Make root override protection evidence",
    )
    for docs_file in ("README.md", "VISION.md", "SECURITY.md", "CHANGES.md"):
        require("GitHub Actions" in read_text(docs_file), f"{docs_file} must document the GitHub Actions baseline")


def main():
    checks = [
        check_docs_plans,
        check_project_files_parse,
        check_xcode_project_contracts,
        check_app_delegate_contracts,
        check_visible_appearance_state,
        check_executable_tests,
        check_manual_verification_docs,
        check_ci_baseline_docs,
    ]
    try:
        for check in checks:
            check()
    except (
        AssertionError,
        ET.ParseError,
        KeyError,
        json.JSONDecodeError,
        plistlib.InvalidFileException,
    ) as exc:
        return fail(str(exc))

    print(f"tvOS static contracts passed ({len(checks)} checks).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
