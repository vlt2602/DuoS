#import "DuoSLocationController.h"
#import "DuoSCarPlayState.h"

@interface DuoSLocationController ()
@property(nonatomic, strong, readwrite) CLLocationManager *manager;
@property(nonatomic) BOOL active;
@end
@implementation DuoSLocationController
- (instancetype)initWithDelegate:(id<CLLocationManagerDelegate>)delegate {
    if ((self = [super init])) {
        _manager = [CLLocationManager new];
        _manager.delegate = delegate;
        _manager.activityType = CLActivityTypeAutomotiveNavigation;
        _manager.pausesLocationUpdatesAutomatically = YES;
    }
    return self;
}
- (void)refreshWithUserPermission:(BOOL)enabled {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshWithUserPermission:enabled];
        });
        return;
    }
    NSArray *modes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
    BOOL declared = [modes isKindOfClass:[NSArray class]] &&
                    [modes containsObject:@"location"];
    /* AuthorizedAlways required for background capture in an app-owned session.
     * Never trigger a permission prompt on behalf of another application. */
    BOOL authorized = self.manager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways;
    BOOL run = enabled && declared && authorized &&
               DuoSCarPlayIsVerifiedConnected() &&
               [CLLocationManager locationServicesEnabled];
    if (!run) { [self stop]; return; }
    if (self.active) return;
    self.manager.allowsBackgroundLocationUpdates = YES;
    self.manager.pausesLocationUpdatesAutomatically = YES;
    [self.manager startUpdatingLocation];
    self.active = YES;
}
- (void)stop {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self stop]; });
        return;
    }
    if (self.active) [self.manager stopUpdatingLocation];
    self.manager.allowsBackgroundLocationUpdates = NO;
    self.manager.pausesLocationUpdatesAutomatically = YES;
    self.active = NO;
}
@end
