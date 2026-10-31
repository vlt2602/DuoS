# DuoS - rootless arm64 on iPhone 7 / iOS 15.8.8.
THEOS ?= $(HOME)/theos
export THEOS
export THEOS_PACKAGE_SCHEME := rootless
export TARGET := iphone:clang:16.5:15.0
export ARCHS := arm64
export DEBUG := 0
export FINALPACKAGE := 1

# Modules: SpringBoard safety; optional UIKit compatibility;
# local HUD source; CarPlayApp observer/HUD; Vietnamese preferences.
SUBPROJECTS = DuoSCore DuoSApps DuoSHUD DuoSCarPlay DuoSPrefs
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
