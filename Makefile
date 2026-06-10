.PHONY: build check lint test verify

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PYTHON ?= python3

lint:
	$(PYTHON) "$(ROOT)/scripts/check_tvos_contracts.py"

test: lint

build:
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd "$(ROOT)" && xcodebuild -project tvos-darkmode.xcodeproj -scheme tvos-darkmode -sdk appletvsimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "tvOS build skipped: xcodebuild is not available on this host."; \
	fi

verify: lint test build

check: verify
