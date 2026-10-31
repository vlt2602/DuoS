#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

static CFStringRef const kDuoSPrefsDomain = CFSTR("com.duos.preferences");
static CFStringRef const kDuoSPrefsChanged = CFSTR("com.duos.preferences.changed");

@interface DuoSRootListController : PSListController
@end

@implementation DuoSRootListController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    if (![[specifier propertyForKey:@"key"] isEqualToString:@"enabled"]) return @NO;
    CFPreferencesAppSynchronize(kDuoSPrefsDomain);
    Boolean valid = false;
    Boolean value = CFPreferencesGetAppBooleanValue(
        CFSTR("enabled"), kDuoSPrefsDomain, &valid);
    return @(valid && value);
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    if (![[specifier propertyForKey:@"key"] isEqualToString:@"enabled"]) return;
    CFPreferencesSetAppValue(CFSTR("enabled"),
                             [value boolValue] ? kCFBooleanTrue : kCFBooleanFalse,
                             kDuoSPrefsDomain);
    // Chi thong bao sau khi ghi cau hinh thanh cong.
    if (CFPreferencesAppSynchronize(kDuoSPrefsDomain)) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                              kDuoSPrefsChanged, NULL, NULL, true);
    } else {
        NSLog(@"[DuoS] Could not persist enabled preference");
    }
}
@end
