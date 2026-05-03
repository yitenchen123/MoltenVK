XC_PROJ := MoltenVKPackaging.xcodeproj
XC_SCHEME := MoltenVK Package

XCODEBUILD := set -o pipefail && $(shell command -v xcodebuild)
# Used to determine if xcpretty is available
XCPRETTY_PATH := $(shell command -v xcpretty 2> /dev/null)

OUTPUT_FMT_CMD =
ifdef XCPRETTY_PATH
	# Pipe output to xcpretty, while preserving full log as xcodebuild.log
	OUTPUT_FMT_CMD = | tee "xcodebuild.log" | xcpretty -c
else
	# Use xcodebuild -quiet parameter
	OUTPUT_FMT_CMD = -quiet
endif

# Collect all build settings defined on the command-line (eg: MVK_HIDE_VULKAN_SYMBOLS=1, MVK_CONFIG_LOG_LEVEL=3...)
MAKEARGS := $(strip \
  $(foreach v,$(.VARIABLES),\
    $(if $(filter command\ line,$(origin $(v))),\
      $(v)=$(value $(v)) ,)))

# Specify individually (not as dependencies) so the sub-targets don't run in parallel
# maccat is currently excluded from `all` because of unresolved build issues on Mac Catalyst platform.
.PHONY: all
all:
	@$(MAKE) macos
	@$(MAKE) ios
	@$(MAKE) iossim
#	@$(MAKE) maccat
	@$(MAKE) tvos
	@$(MAKE) tvossim
	@$(MAKE) visionos       # Requires Xcode 15+
	@$(MAKE) visionossim    # Requires Xcode 15+

.PHONY: all-debug
all-debug:
	@$(MAKE) macos-debug
	@$(MAKE) ios-debug
	@$(MAKE) iossim-debug
#	@$(MAKE) maccat-debug
	@$(MAKE) tvos-debug
	@$(MAKE) tvossim-debug
	@$(MAKE) visionos-debug       # Requires Xcode 15+
	@$(MAKE) visionossim-debug    # Requires Xcode 15+

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

# ---- iOS 动态库 (fat dylib) 构建目标 ----
# 原理：先构建真机和模拟器的静态框架（make ios iossim），
#       再从静态库中提取对象并重新链接为动态库，最后合并。
.PHONY: iosfatdylib
iosfatdylib:
	@echo "==== 构建 iOS 真机 + 模拟器静态库 ===="
	@$(MAKE) ios iossim
	@echo "==== 准备输出目录 ===="
	@mkdir -p Package/Release/MoltenVK/dynamic/dylib/iOS
	@echo "==== 定位静态库文件 ===="
	@DEVICE_LIB=$$(find Package/Release/MoltenVK/static -name MoltenVK -path "*/iphoneos/*" | head -1); \
	SIM_LIB=$$(find Package/Release/MoltenVK/static -name MoltenVK -path "*/iphonesimulator/*" | head -1); \
	if [ -z "$$DEVICE_LIB" ] || [ -z "$$SIM_LIB" ]; then \
		echo "错误：找不到静态库文件"; exit 1; \
	fi; \
	echo "真机静态库: $$DEVICE_LIB"; \
	echo "模拟器静态库: $$SIM_LIB"; \
	\
	echo "==== 链接真机动态库 ===="; \
	xcrun --sdk iphoneos clang++ -dynamiclib -arch arm64 \
		-o Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-device.dylib \
		$$DEVICE_LIB \
		-framework IOSurface -framework CoreGraphics -framework UIKit \
		-framework Metal -framework QuartzCore -framework Foundation \
		-fobjc-arc -fobjc-link-runtime; \
	\
	echo "==== 链接模拟器动态库 ===="; \
	xcrun --sdk iphonesimulator clang++ -dynamiclib -arch arm64 \
		-o Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-sim.dylib \
		$$SIM_LIB \
		-framework IOSurface -framework CoreGraphics -framework UIKit \
		-framework Metal -framework QuartzCore -framework Foundation \
		-fobjc-arc -fobjc-link-runtime; \
	\
	echo "==== 合并为胖二进制 ===="; \
	lipo -create \
		Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-device.dylib \
		Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-sim.dylib \
		-output Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK.dylib; \
	\
	echo "==== 清理临时文件 ===="; \
	rm Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-device.dylib \
	   Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK-sim.dylib; \
	\
	echo "==== iOS 动态库构建完成：Package/Release/MoltenVK/dynamic/dylib/iOS/libMoltenVK.dylib ===="

# Usually requires 'sudo make install'
.PHONY: install
install:
	$ rm -f /usr/local/lib/libMoltenVK.dylib
	$ cp -p Package/Latest/MoltenVK/dynamic/dylib/macOS/libMoltenVK.dylib /usr/local/lib