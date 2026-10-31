include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = DuoS
DuoS_FILES = main.m DuoSAppDelegate.m DuoSPhoneSceneDelegate.m DuoSCarPlaySceneDelegate.m DuoSRootViewController.m DuoSSpeedProvider.m ../DuoSCore/DuoSGeometry.c ../Shared/DuoSHUDLayer.m ../Shared/DuoSSpeedMath.c
DuoS_CFLAGS = -fobjc-arc -O2 -Wall
DuoS_FRAMEWORKS = Foundation UIKit QuartzCore CoreLocation CarPlay
DuoS_INSTALL_PATH = /Applications

include $(THEOS_MAKE_PATH)/application.mk
