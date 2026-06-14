.PHONY: build check lint test verify

override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PYTHON ?= python3
TVOS_DESTINATION ?= platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=18.5

lint:
	$(PYTHON) "$(ROOT)/scripts/check_tvos_contracts.py"

test: lint
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd "$(ROOT)" && xcodebuild -project tvos-darkmode.xcodeproj -scheme tvos-darkmode -destination "$(TVOS_DESTINATION)" -configuration Debug CODE_SIGNING_ALLOWED=NO test; \
	else \
		echo "tvOS XCTest skipped: xcodebuild is not available on this host."; \
	fi

build:
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd "$(ROOT)" && xcodebuild -project tvos-darkmode.xcodeproj -scheme tvos-darkmode -destination "generic/platform=tvOS Simulator" -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "tvOS build skipped: xcodebuild is not available on this host."; \
	fi

verify: lint test build

check: verify
