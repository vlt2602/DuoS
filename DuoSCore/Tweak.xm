#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

// DuoS Core: chi quan sat man hinh ngoai, khong hook private API.
// Theo doi man hinh MAC DINH TAT va co the tat ngay trong Settings.

static CFStringRef const kDuoSPrefsDomain = CFSTR("com.duos.preferences");
static CFStringRef const kDuoSPrefsChanged = CFSTR("com.duos.preferences.changed");

typedef NS_ENUM(NSInteger, DuoSLayoutMode) {
    DuoSLayoutModeEqual = 0,
    DuoSLayoutModeWideLeft = 1
};

@interface DuoSCoreState : NSObject
@property (nonatomic, assign, readonly) BOOL enabled;
@property (nonatomic, assign, readonly) BOOL externalDisplayConnected;
@property (nonatomic, assign, readonly) DuoSLayoutMode layoutMode;
@property (nonatomic, assign, readonly) CGFloat splitFraction;
+ (instancetype)shared;
- (void)start;
- (void)reloadPreferences;
- (void)selectLayout:(DuoSLayoutMode)layout;
@end

static void DuoSPrefsDidChange(CFNotificationCenterRef center, void *observer,
                               CFStringRef name, const void *object,
                               CFDictionaryRef userInfo);

@interface DuoSCoreState ()
@property (nonatomic, assign, readwrite) BOOL enabled;
@property (nonatomic, assign, readwrite) BOOL externalDisplayConnected;
@property (nonatomic, assign, readwrite) DuoSLayoutMode layoutMode;
@property (nonatomic, assign, readwrite) CGFloat splitFraction;
@end

@implementation DuoSCoreState {
    id _screenConnectedObserver;
    id _screenDisconnectedObserver;
    BOOL _prefsObserverRegistered;
}

+ (instancetype)shared {
    static DuoSCoreState *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _layoutMode = DuoSLayoutModeEqual;
    _splitFraction = 0.5;
    _enabled = NO;
    _externalDisplayConnected = NO;
    return self;
}

- (void)selectLayout:(DuoSLayoutMode)layout {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self selectLayout:layout]; });
        return;
    }
    if (layout != DuoSLayoutModeEqual && layout != DuoSLayoutModeWideLeft)
        layout = DuoSLayoutModeEqual;
    self.layoutMode = layout;
    self.splitFraction = (layout == DuoSLayoutModeWideLeft) ? 0.65 : 0.5;
}

- (void)refreshExternalDisplayState {
    if (!self.enabled) return;
    // UIScreen khong phan biet duoc CarPlay voi cac man hinh ngoai khac.
    BOOL present = [UIScreen screens].count > 1;
    if (self.externalDisplayConnected == present) return;
    self.externalDisplayConnected = present;
    NSLog(@"[DuoS] External screen %@", present ? @"connected" : @"disconnected");
}

- (void)startScreenObservation {
    if (_screenConnectedObserver || _screenDisconnectedObserver) return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    __weak typeof(self) weakSelf = self;
    _screenConnectedObserver =
      [center addObserverForName:UIScreenDidConnectNotification
                         object:nil queue:[NSOperationQueue mainQueue]
                     usingBlock:^(__unused NSNotification *note) {
        [weakSelf refreshExternalDisplayState];
    }];
    _screenDisconnectedObserver =
      [center addObserverForName:UIScreenDidDisconnectNotification
                         object:nil queue:[NSOperationQueue mainQueue]
                     usingBlock:^(__unused NSNotification *note) {
        [weakSelf refreshExternalDisplayState];
    }];
    [self refreshExternalDisplayState];
}

- (void)stopScreenObservation {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (_screenConnectedObserver) {
        [center removeObserver:_screenConnectedObserver];
        _screenConnectedObserver = nil;
    }
    if (_screenDisconnectedObserver) {
        [center removeObserver:_screenDisconnectedObserver];
        _screenDisconnectedObserver = nil;
    }
    self.externalDisplayConnected = NO;
}

- (void)reloadPreferences {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self reloadPreferences]; });
        return;
    }
    // Khong co khoa enabled hoac kieu gia tri sai => fail closed (OFF).
    CFPreferencesAppSynchronize(kDuoSPrefsDomain);
    Boolean valid = false;
    Boolean enabledValue = CFPreferencesGetAppBooleanValue(
        CFSTR("enabled"), kDuoSPrefsDomain, &valid);
    BOOL shouldEnable = (valid && enabledValue);
    if (self.enabled == shouldEnable) return;

    self.enabled = shouldEnable;
    if (shouldEnable) [self startScreenObservation];
    else [self stopScreenObservation];
    NSLog(@"[DuoS] Passive observation %@", shouldEnable ? @"enabled" : @"disabled");
}

- (void)start {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self start]; });
        return;
    }
    if (!_prefsObserverRegistered) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (__bridge const void *)self,
                                        DuoSPrefsDidChange, kDuoSPrefsChanged,
                                        NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        _prefsObserverRegistered = YES;
    }
    [self reloadPreferences];
}

- (void)dealloc {
    [self stopScreenObservation];
    if (_prefsObserverRegistered) {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                            (__bridge const void *)self,
                                            kDuoSPrefsChanged, NULL);
    }
}
@end

static void DuoSPrefsDidChange(__unused CFNotificationCenterRef center,
                               void *observer, __unused CFStringRef name,
                               __unused const void *object,
                               __unused CFDictionaryRef userInfo) {
    DuoSCoreState *state = (__bridge DuoSCoreState *)observer;
    if (!state) return;
    // Darwin callback co the chay tren thread khac.
    dispatch_async(dispatch_get_main_queue(), ^{ [state reloadPreferences]; });
}

%ctor {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DuoSCoreState shared] start];
        });
    }
}
