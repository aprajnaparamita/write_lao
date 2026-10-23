FLUTTER = /Users/dara/dev/flutter/bin/flutter
SHELL   = /bin/bash

.PHONY: deploy deploy-phone deploy-ipad devices secrets codegen test clean dmg apk aab

## ── Open-source / store distribution ────────────────────────────────────────

# macOS .dmg with the full vocabulary unlocked (open-source build)
dmg:
	@bash scripts/build_macos_dmg.sh

# Android APK for sideloading (adb install) with the full vocabulary unlocked
apk:
	@bash scripts/build_android.sh apk

# Android App Bundle for the Play Store (vocabulary behind in-app purchase)
aab:
	@bash scripts/build_android.sh aab

## ── App Store archive ────────────────────────────────────────────────────────

# Build a signed App Store IPA ready for upload.
# Opens Xcode Organizer afterward so you can upload with one click.
archive:
	@bash scripts/setup_secrets.sh
	@echo "▶ Building release archive…"
	@$(FLUTTER) build ipa --release
	@echo "▶ Unlinking Homebrew rsync (Xcode compatibility)…"
	@brew unlink rsync 2>/dev/null || true
	@echo "▶ Exporting IPA…"
	@rm -rf /tmp/WriteLao_ipa
	@xcodebuild -exportArchive \
		-archivePath build/ios/archive/Runner.xcarchive \
		-exportPath /tmp/WriteLao_ipa \
		-exportOptionsPlist build/ios/ExportOptions.plist \
		-allowProvisioningUpdates 2>&1 | grep -v "^\s*$$"
	@brew link rsync 2>/dev/null || true
	@mkdir -p build/ios/ipa
	@cp -f /tmp/WriteLao_ipa/*.ipa build/ios/ipa/
	@echo ""
	@echo "✅  IPA ready: $$(ls -lh build/ios/ipa/*.ipa | awk '{print $$9, $$5}')"
	@echo "▶ Opening Xcode Organizer to upload…"
	@open build/ios/archive/Runner.xcarchive

## ── Deploy ───────────────────────────────────────────────────────────────────

# Build release + install on ALL connected iOS devices
deploy:
	@bash scripts/deploy_ios.sh

# Install on the iPhone only
deploy-phone:
	@bash scripts/deploy_ios.sh --phone

# Install on the iPad only
deploy-ipad:
	@bash scripts/deploy_ios.sh --ipad

# List connected iOS devices without building
devices:
	@bash scripts/deploy_ios.sh --list

## ── Dev helpers ──────────────────────────────────────────────────────────────

# Regenerate lib/config/secrets.dart from .env
secrets:
	@bash scripts/setup_secrets.sh

# Run code generation (Freezed, Riverpod, Hive)
codegen:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

# Run all tests
test:
	$(FLUTTER) test

# Wipe build cache
clean:
	$(FLUTTER) clean
