APP_NAME = PomodoroNotch
BUILD_DIR = .build/debug
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
BINARY = $(BUILD_DIR)/$(APP_NAME)

.PHONY: build run clean app

build:
	swift build

app: build
	rm -rf "$(APP_BUNDLE)"
	mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	cp "$(BINARY)" "$(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)"
	plutil -create xml1 "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace CFBundleExecutable -string "$(APP_NAME)" "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace CFBundleIdentifier -string "com.pomodoro.notch" "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace CFBundleName -string "番茄时钟" "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace CFBundleDisplayName -string "番茄时钟" "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace CFBundleVersion -string "1" "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace CFBundleShortVersionString -string "1.0" "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace CFBundlePackageType -string "APPL" "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace LSMinimumSystemVersion -string "14.0" "$(APP_BUNDLE)/Contents/Info.plist"
	plutil -replace LSUIElement -bool YES "$(APP_BUNDLE)/Contents/Info.plist"
	@echo "Bundle created at $(APP_BUNDLE)"
	@echo "Run: make run"

run: app
	open "$(APP_BUNDLE)"

clean:
	rm -rf .build
