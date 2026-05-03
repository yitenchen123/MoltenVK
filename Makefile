XC_PROJ := MoltenVKPackaging.xcodeproj
XC_SCHEME := MoltenVK Package

XCODEBUILD := set -o pipefail && $(shell command -v xcodebuild)
XCPRETTY_PATH := $(shell command -v xcpretty 2> /dev/null)

OUTPUT_FMT_CMD =
ifdef XCPRETTY_PATH
	OUTPUT_FMT_CMD = | tee "xcodebuild.log" | xcpretty -c
else
	OUTPUT_FMT_CMD = -quiet
endif

MAKEARGS := $(strip \
  $(foreach v,$(.VARIABLES),\
    $(if $(filter command\ line,$(origin $(v))),\
      $(v)=$(value $(v)) ,)))

.PHONY: all
all:
	@$(MAKE) macos
	@$(MAKE) ios
	@$(MAKE) iossim
	@$(MAKE) tvos
	@$(MAKE) tvossim
	@$(MAKE) visionos
	@$(MAKE) visionossim

.PHONY: all-debug
all-debug:
	@$(MAKE) macos-debug
	@$(MAKE) ios-debug
	@$(MAKE) iossim-debug
	@$(MAKE) tvos-debug
	@$(MAKE) tvossim-debug
	@$(MAKE) visionos-debug
	@$(MAKE) visionossim-debug

.PHONY: macos
macos:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (macOS only)" -destination "generic/platform=macOS" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: macos-debug
macos-debug:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (macOS only)" -destination "generic/platform=macOS" -configuration "Debug" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: ios
ios:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (iOS only)" -destination "generic/platform=iOS" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: ios-debug
ios-debug:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (iOS only)" -destination "generic/platform=iOS" -configuration "Debug" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: iossim
iossim:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (iOS only)" -destination "generic/platform=iOS Simulator" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: iossim-debug
iossim-debug:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (iOS only)" -destination "generic/platform=iOS Simulator" -configuration "Debug" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: maccat
maccat:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (MacCat only)" -destination "generic/platform=macOS,variant=Mac Catalyst" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: maccat-debug
maccat-debug:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (MacCat only)" -destination "generic/platform=macOS,variant=Mac Catalyst" -configuration "Debug" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: tvos
tvos:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (tvOS only)" -destination "generic/platform=tvOS" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: tvos-debug
tvos-debug:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (tvOS only)" -destination "generic/platform=tvOS" -configuration "Debug" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: tvossim
tvossim:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (tvOS only)" -destination "generic/platform=tvOS Simulator" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: tvossim-debug
tvossim-debug:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (tvOS only)" -destination "generic/platform=tvOS Simulator" -configuration "Debug" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: visionos
visionos:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (visionOS only)" -destination "generic/platform=xrOS" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: visionos-debug
visionos-debug:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (visionOS only)" -destination "generic/platform=xrOS" -configuration "Debug" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: visionossim
visionossim:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (visionOS only)" -destination "generic/platform=xrOS Simulator" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: visionossim-debug
visionossim-debug:
	$(XCODEBUILD) build -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (visionOS only)" -destination "generic/platform=xrOS Simulator" -configuration "Debug" GCC_PREPROCESSOR_DEFINITIONS='$${inherited} $(MAKEARGS)' $(OUTPUT_FMT_CMD)

.PHONY: clean
clean:
	$(XCODEBUILD) clean -project "$(XC_PROJ)" -scheme "$(XC_SCHEME) (macOS only)" -destination "generic/platform=macOS" $(OUTPUT_FMT_CMD)
	rm -rf Package

# ---- iOS 动态库 (fat dylib) 构建 ----
# 使用 make ios 先构建真机静态库，再将其转换成 dylib
# 若模拟器构建成功，则合并为胖二进制
.PHONY: iosfatdylib
iosfatdylib:
	@echo "==== 构建 iOS 真机静态库 ===="
	@$(MAKE) ios
	@echo "==== 准备输出目录 ===="
	@mkdir -p Package/Release/MoltenVK/dynamic/dylib/iOS
	@echo "==== 定位真机静态库 ===="
	@DEVICE_LIB=Package/Release/MoltenVK/static/MoltenVK.xcframework/ios-arm64/libMoltenVK.a; \
	if [ ! -f "$$DEVICE_LIB" ]; then \
		echo "错误：真机静态库不存在：$$DEVICE_LIB"; exit 1; \
	fi; \
	echo "真机静态库: $$DEVICE_LIB"; \
	\
	echo "==== 尝试构建模拟器静态库 ===="; \
	$(MAKE) iossim 2>/dev/null; \
	SIM_LIB=Package/Release/MoltenVK/static/MoltenVK.xcframework/ios-simulator-arm64/libMoltenVK.a; \
	if [ -f "$$SIM_LIB" ]; then \
		echo "模拟器静态库: $$SIM_LIB，将生成 fat 动态库"; \
		xcrun --sdk iphoneos clang++ -dynamiclib -arch arm64 \
			-o Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-device.dylib \
			$$DEVICE_LIB \
			-framework IOSurface -framework CoreGraphics -framework UIKit \
			-framework Metal -framework QuartzCore -framework Foundation \
			-fobjc-arc -fobjc-link-runtime; \
		xcrun --sdk iphonesimulator clang++ -dynamiclib -arch arm64 \
			-o Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-sim.dylib \
			$$SIM_LIB \
			-framework IOSurface -framework CoreGraphics -framework UIKit \
			-framework Metal -framework QuartzCore -framework Foundation \
			-fobjc-arc -fobjc-link-runtime; \
		lipo -create \
			Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-device.dylib \
			Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-sim.dylib \
			-output Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK.dylib; \
		rm Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-device.dylib \
		   Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-sim.dylib; \
	else \
		echo "模拟器静态库不存在，仅生成真机动态库"; \
		xcrun --sdk iphoneos clang++ -dynamiclib -arch arm64 \
			-o Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK.dylib \
			$$DEVICE_LIB \
			-framework IOSurface -framework CoreGraphics -framework UIKit \
			-framework Metal -framework QuartzCore -framework Foundation \
			-fobjc-arc -fobjc-link-runtime; \
	fi; \
	echo "==== iOS 动态库构建完成 ===="

# Usually requires 'sudo make install'
.PHONY: install
install:
	$ rm -f /usr/local/lib/libMoltenVK.dylib
	$ cp -p Package/Latest/MoltenVK/dynamic/dylib/macOS/libMoltenVK.dylib /usr/local/lib