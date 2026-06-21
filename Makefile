.DEFAULT_GOAL := check
.PHONY: __repository-make-authority build check lint root-test test verify

PUBLIC_TARGETS := build check lint root-test test verify

PYTHON ?= python3
override PYTHON := $(value PYTHON)
export PYTHON
override REPOSITORY_MAKE_DOLLAR := $$
override REPOSITORY_MAKE_OPEN := (
ifneq ($(findstring $(REPOSITORY_MAKE_DOLLAR)$(REPOSITORY_MAKE_OPEN),$(value PYTHON)),)
$(error PYTHON must be a literal executable path, not Make syntax)
endif
override SHELL := /bin/sh
override .SHELLFLAGS := -c

ifneq ($(filter command line,$(origin MAKEFLAGS)),)
$(error MAKEFLAGS must not be overridden for repository verification)
endif
override REPOSITORY_MAKE_FIRST_FLAGS := $(firstword $(MAKEFLAGS))
ifneq ($(filter -%,$(REPOSITORY_MAKE_FIRST_FLAGS)),)
override REPOSITORY_MAKE_FIRST_FLAGS :=
endif
override REPOSITORY_MAKE_SHORT_FLAGS := $(REPOSITORY_MAKE_FIRST_FLAGS) $(filter-out --%,$(filter -%,$(MAKEFLAGS)))
ifneq ($(findstring n,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring t,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring q,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring i,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(filter --just-print --dry-run --recon --touch --question --ignore-errors,$(MAKEFLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override REPOSITORY_MAKEFILE := $(lastword $(MAKEFILE_LIST))
override REPOSITORY_ROOT := $(abspath $(dir $(REPOSITORY_MAKEFILE)))
override ROOT := $(REPOSITORY_ROOT)
export ROOT
TVOS_DESTINATION ?=
DERIVED_DATA_PATH ?= $(ROOT)/.build/DerivedData

$(PUBLIC_TARGETS): override SHELL := /bin/sh
$(PUBLIC_TARGETS): override .SHELLFLAGS := -c
$(PUBLIC_TARGETS): override ROOT := $(REPOSITORY_ROOT)
$(PUBLIC_TARGETS): __repository-make-authority

__repository-make-authority:
	@:

lint:
	"$$PYTHON" "$$ROOT/scripts/check_tvos_contracts.py"
	cd "$$ROOT" && "$$PYTHON" -m unittest discover -s tests -p 'test_*.py'

test: lint
	@if command -v xcodebuild >/dev/null 2>&1; then \
		destination='$(TVOS_DESTINATION)'; \
		if [ -z "$$destination" ]; then destination="$$($$PYTHON "$$ROOT/scripts/select_tvos_destination.py")"; fi; \
		cd "$$ROOT" && xcodebuild -project tvos-darkmode.xcodeproj -scheme tvos-darkmode -destination "$$destination" -derivedDataPath "$(DERIVED_DATA_PATH)" -configuration Debug CODE_SIGNING_ALLOWED=NO test; \
	else \
		echo "tvOS XCTest skipped: xcodebuild is not available on this host."; \
	fi

build:
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd "$$ROOT" && xcodebuild -project tvos-darkmode.xcodeproj -scheme tvos-darkmode -destination "generic/platform=tvOS Simulator" -derivedDataPath "$(DERIVED_DATA_PATH)" -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "tvOS build skipped: xcodebuild is not available on this host."; \
	fi

root-test:
	/bin/sh "$$ROOT/scripts/test-makefile-authority.sh"

verify: root-test lint test build

check: verify
