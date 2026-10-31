#import "DuoSSpeedProvider.h"
#import "../Shared/DuoSSpeedMath.h"
#import <UIKit/UIKit.h>

@interface DuoSSpeedProvider ()
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, assign, readwrite) BOOL active;
@end

@implementation DuoSSpeedProvider

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    _manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _manager.distanceFilter = 10.0;
    // Bao ve pin: dung ngay khi app vao background, khong co timer.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWentBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    return self;
}

- (void)send:(NSInteger)value detail:(NSString *)detail {
    id<DuoSSpeedProviderDelegate> handler = self.delegate;
    if (!handler) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler duosSpeedChanged:value detail:detail];
    });
}

- (void)startWithUserAction {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self startWithUserAction]; });
        return;
    }
    if (self.active) return;
    CLAuthorizationStatus status = [self.manager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.manager requestWhenInUseAuthorization];
        [self send:-1 detail:@"Can quyen Vi tri khi su dung app"];
        return;
    }
    if (status != kCLAuthorizationStatusAuthorizedWhenInUse &&
        status != kCLAuthorizationStatusAuthorizedAlways) {
        [self send:-1 detail:@"Khong duoc cap quyen Vi tri"];
        return;
    }
    self.active = YES;
    [self.manager startUpdatingLocation];
    [self send:-1 detail:@"Dang nhan GPS thuc"];
}

- (void)stop {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self stop]; });
        return;
    }
    [self.manager stopUpdatingLocation];
    self.active = NO;
    [self send:-1 detail:@"Da dung GPS"];
}

- (void)appWentBackground:(__unused NSNotification *)note {
    if (self.active) [self stop];
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus status = [manager authorizationStatus];
    if (status != kCLAuthorizationStatusAuthorizedWhenInUse &&
        status != kCLAuthorizationStatusAuthorizedAlways) {
        [self stop];
        [self send:-1 detail:@"GPS chua duoc cap quyen"];
    } else {
        // Khong tu dong khoi dong khi duoc cap quyen; yeu cau bam lai.
        [self send:-1 detail:@"Da co quyen GPS, bam Bat GPS lan nua"];
    }
}

- (void)locationManager:(__unused CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.active) return;
    CLLocation *last = locations.lastObject;
    if (!last || last.horizontalAccuracy < 0.0 ||
        last.horizontalAccuracy > 65.0) {
        [self send:-1 detail:@"GPS chua du chinh xac"];
        return;
    }
    NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:last.timestamp];
    int speedKmh = -1;
    if (!DuoSSpeedKmhFromMetersPerSecond(last.speed, age, &speedKmh)) {
        [self send:-1 detail:@"Mau GPS cu hoac khong hop le"];
        return;
    }
    [self send:(NSInteger)speedKmh detail:@"Toc do GPS thuc - chi tren iPhone"];
}

- (void)locationManager:(__unused CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error.code == kCLErrorLocationUnknown) return;
    [self stop];
    [self send:-1 detail:@"Khong lay duoc du lieu GPS"];
}

- (void)dealloc {
    [self.manager stopUpdatingLocation];
    self.manager.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
