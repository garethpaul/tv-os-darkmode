.PHONY: build check lint test verify

PYTHON ?= python3

lint:
	$(PYTHON) scripts/check_tvos_contracts.py

test: lint

build:
	@if command -v xcodebuild >/dev/null 2>&1; then \
		xcodebuild -project tvos-darkmode.xcodeproj -scheme tvos-darkmode -sdk appletvsimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "tvOS build skipped: xcodebuild is not available on this host."; \
	fi

verify: lint test build

check: verify
