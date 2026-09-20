.DEFAULT_GOAL := help
APP_NAME := SmartSelect
BUILD_DIR := build
CONFIG := release

.PHONY: help build release test app app-clt clean lint format run

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

build: ## Debug build of the executable
	swift build

release: ## Release build of the executable
	swift build -c release

test: ## Run the SmartSelectCore test suite
	swift test

app: release ## Bundle a runnable SmartSelect.app into ./build (needs full Xcode)
	@bash scripts/package-app.sh $(CONFIG)

app-clt: ## Bundle SmartSelect.app using only Command Line Tools (no Xcode)
	@bash scripts/build-clt.sh

run: app ## Build the app bundle and launch it
	open $(BUILD_DIR)/$(APP_NAME).app

lint: ## Run swiftlint if installed
	@command -v swiftlint >/dev/null 2>&1 && swiftlint || echo "swiftlint not installed — skipping"

format: ## Run swift-format if installed
	@command -v swift-format >/dev/null 2>&1 && swift-format -i -r Sources Tests || echo "swift-format not installed — skipping"

clean: ## Remove build artifacts
	swift package clean
	rm -rf $(BUILD_DIR) .build
