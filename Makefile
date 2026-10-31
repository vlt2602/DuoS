# DuoS Rootless: app tren iPhone + tweak module tach rieng.
THEOS ?= $(HOME)/theos
export THEOS
export THEOS_PACKAGE_SCHEME := rootless
export TARGET := iphone:clang:16.5:15.0
export ARCHS := arm64
export DEBUG := 0
export FINALPACKAGE := 1

SUBPROJECTS = DuoSCore DuoSApps DuoSHUD DuoSPrefs DuoSApp

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
