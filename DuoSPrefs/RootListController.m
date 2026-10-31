#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../Shared/DuoSHUDLayer.h"
#import "DuoSLayoutPreviewController.h"

static CFStringRef const kDuoSPrefsDomain = CFSTR("com.duos.preferences");
static CFStringRef const kDuoSPrefsChanged = CFSTR("com.duos.preferences.changed");

// Man hinh kiem thu giao dien: so lieu co dinh, khong xin quyen vi tri.
@interface DuoSHUDPreviewController : UIViewController
@property (nonatomic, strong) DuoSHUDLayer *speedLayer;
@end

@implementation DuoSHUDPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HUD - Xem thử";
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    DuoSHUDLayer *hud = [DuoSHUDLayer layer];
    hud.speedKmh = 88; // So mau tinh, KHONG phai toc do GPS.
    self.speedLayer = hud;
    [self.view.layer addSublayer:hud];

    CATextLayer *caption = [CATextLayer layer];
    caption.name = @"duos.preview.caption";
    caption.string = @"DỮ LIỆU MẪU - KHÔNG PHẢI TỐC ĐỘ THỰC";
    caption.fontSize = 12;
    caption.alignmentMode = kCAAlignmentCenter;
    caption.foregroundColor = UIColor.secondaryLabelColor.CGColor;
    caption.contentsScale = [UIScreen mainScreen].scale;
    [self.view.layer addSublayer:caption];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    const CGRect bounds = self.view.bounds;
    CGFloat width = MIN(MAX(0.0, CGRectGetWidth(bounds) - 40.0), 240.0);
    CGFloat height = 200.0;
    CGFloat originY = MAX(30.0, (CGRectGetHeight(bounds) - height) / 2.0 - 35.0);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.speedLayer.frame = CGRectMake((CGRectGetWidth(bounds)-width)/2.0,
                                       originY, width, height);
    for (CALayer *child in self.view.layer.sublayers) {
        if ([child.name isEqualToString:@"duos.preview.caption"]) {
            child.frame = CGRectMake(0.0, originY + height + 28.0,
                                     CGRectGetWidth(bounds), 26.0);
            break;
        }
    }
    [CATransaction commit];
}
@end

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
    if (CFPreferencesAppSynchronize(kDuoSPrefsDomain)) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                              kDuoSPrefsChanged, NULL, NULL, true);
    } else {
        NSLog(@"[DuoS] Could not persist enabled preference");
    }
}

- (void)showHUDPreview:(__unused PSSpecifier *)specifier {
    DuoSHUDPreviewController *preview = [[DuoSHUDPreviewController alloc] init];
    [self.navigationController pushViewController:preview animated:YES];
}

- (void)showLayoutPreview:(__unused PSSpecifier *)specifier {
    DuoSLayoutPreviewController *preview = [[DuoSLayoutPreviewController alloc] init];
    [self.navigationController pushViewController:preview animated:YES];
}
@end
