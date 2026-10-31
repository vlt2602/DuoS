# DuoS - Rootless build entry point.
# THEOS duoc truyen tu GitHub Actions hoac mac dinh ~/theos.
THEOS ?= $(HOME)/theos
export THEOS

export THEOS_PACKAGE_SCHEME := rootless
export TARGET := iphone:clang:16.5:15.0
export ARCHS := arm64
export DEBUG := 0
export FINALPACKAGE := 1

# Chi dung ARM64 tren iPhone 7 (A10), khong can arm64e.
# SUBPROJECTS duoc xay dung theo thu tu sau.
SUBPROJECTS = DuoSCore DuoSApps DuoSHUD DuoSPrefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
