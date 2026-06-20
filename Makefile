.PHONY: build check lint test verify

override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PYTHON ?= python3
TVOS_DESTINATION ?=
DERIVED_DATA_PATH ?= $(ROOT)/.build/DerivedData

lint:
	$(PYTHON) "$(ROOT)/scripts/check_tvos_contracts.py"
	cd "$(ROOT)" && $(PYTHON) -m unittest discover -s tests -p 'test_*.py'

test: lint
	@if command -v xcodebuild >/dev/null 2>&1; then \
		destination='$(TVOS_DESTINATION)'; \
		if [ -z "$$destination" ]; then destination="$$($(PYTHON) "$(ROOT)/scripts/select_tvos_destination.py")"; fi; \
		cd "$(ROOT)" && xcodebuild -project tvos-darkmode.xcodeproj -scheme tvos-darkmode -destination "$$destination" -derivedDataPath "$(DERIVED_DATA_PATH)" -configuration Debug CODE_SIGNING_ALLOWED=NO test; \
	else \
		echo "tvOS XCTest skipped: xcodebuild is not available on this host."; \
	fi

build:
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd "$(ROOT)" && xcodebuild -project tvos-darkmode.xcodeproj -scheme tvos-darkmode -destination "generic/platform=tvOS Simulator" -derivedDataPath "$(DERIVED_DATA_PATH)" -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "tvOS build skipped: xcodebuild is not available on this host."; \
	fi

verify: lint test build

check: verify
