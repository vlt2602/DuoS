#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <notify.h>
#import "../../Shared/DuoSLocationController.h"
#import "../../Shared/DuoSHUDTransport.h"
#import "../../Shared/DuoSCarPlayState.h"
#import <CoreFoundation/CoreFoundation.h>
#include <math.h>
#include <unistd.h>

/* Source only: requires manual user opt-in and WYN's existing location
 * authorization; does not hook, replace or modify WYN's CLLocationManager.
 * Does not launch WYN automatically. */
static BOOL DSLocationEnabled(void) {
    if (access("/var/mobile/Library/Preferences/.duos-disabled",F_OK) == 0) return NO;
    CFPreferencesAppSynchronize(CFSTR("com.duos.preferences"));
    CFPropertyListRef value = CFPreferencesCopyAppValue(
             CFSTR("locationEnabled"), CFSTR("com.duos.preferences"));
    BOOL enabled = value && CFGetTypeID(value) == CFBooleanGetTypeID() &&
                   CFBooleanGetValue((CFBooleanRef)value);
    if (value) CFRelease(value);
    return enabled;
}

@interface DSLocationSource : NSObject <CLLocationManagerDelegate>
@property(nonatomic,strong) DuoSLocationController *owner;
@property(nonatomic) uint16_t sequence;
@property(nonatomic) int stateToken;
@property(nonatomic,strong) dispatch_source_t keepalive;
- (void)refresh;
@end
@implementation DSLocationSource
- (instancetype)init {
    if ((self = [super init])) {
        _stateToken = -1;
        _owner = [[DuoSLocationController alloc] initWithDelegate:self];
        __weak typeof(self) weakSelf = self;
        int token = -1;
        if (notify_register_dispatch("com.duos.carplay.v1.verified", &token,
                 dispatch_get_main_queue(), ^(int t) {
            (void)t;
            [weakSelf refresh];
        }) == NOTIFY_STATUS_OK) _stateToken = token;
        /* Long-tail stale state check: never leave owned GPS running after
         * notification loss or CarPlay process crash. 30s only while WYN runs. */
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0,0,
                                                          dispatch_get_main_queue());
        _keepalive = timer;
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 30*NSEC_PER_SEC),
                         30*NSEC_PER_SEC, 3*NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{ [weakSelf refresh]; });
        dispatch_resume(timer);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(active:)
                  name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(active:)
                  name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
- (void)active:(NSNotification *)note { (void)note; [self refresh]; }
- (void)refresh {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self refresh]; });
        return;
    }
    BOOL enabled = DSLocationEnabled() && DuoSCarPlayIsVerifiedConnected();
    [self.owner refreshWithUserPermission:enabled];
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (manager != self.owner.manager || !DSLocationEnabled() ||
        !DuoSCarPlayIsVerifiedConnected()) {
        [self.owner stop];
        return;
    }
    CLLocation *location = locations.lastObject;
    if (!location || location.horizontalAccuracy < 0 ||
        location.horizontalAccuracy > 100 || !isfinite(location.speed) ||
        location.speed < 0 || location.speed > 100) return;
    double speedKmh = location.speed * 3.6;
    unsigned value = (unsigned)lrint(speedKmh * 10.0);
    if (value > 4094) value = 4094;
    DuoSHUDSample sample = {0};
    sample.speed_tenths = (uint16_t)value;
    sample.limit_kmh = 1023; /* no speed limit from raw GPS */
    sample.flags = 0;
    sample.sequence = (++self.sequence) & 4095;
    sample.uptime_seconds = (uint32_t)[NSProcessInfo processInfo].systemUptime;
    DuoSHUDPublish(&sample);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    (void)manager; (void)error;
    [self.owner stop]; /* fail closed; retry on next user-visible launch */
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.owner stop];
    if (_stateToken >= 0) notify_cancel(_stateToken);
    if (_keepalive) dispatch_source_cancel(_keepalive);
}
@end

%ctor {
    @autoreleasepool {
        if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.wynauto.wyn"]) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            static DSLocationSource *source;
            if (!source) source = [DSLocationSource new];
            [source refresh];
        });
    }
}
