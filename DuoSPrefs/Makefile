include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DuoSPrefs
DuoSPrefs_FILES = RootListController.m DuoSLayoutPreviewController.m ../Shared/DuoSHUDLayer.m ../DuoSCore/DuoSGeometry.c
DuoSPrefs_CFLAGS = -fobjc-arc -O2 -Wall
DuoSPrefs_FRAMEWORKS = Foundation UIKit QuartzCore
DuoSPrefs_PRIVATE_FRAMEWORKS = Preferences
DuoSPrefs_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk
