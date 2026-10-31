#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN
/* Own CLLocationManager only. NEVER modify Waze/GOFA/VietMap/WYN managers. */
@interface DuoSLocationController : NSObject
@property(nonatomic, strong, readonly) CLLocationManager *manager;
- (instancetype)initWithDelegate:(id<CLLocationManagerDelegate> _Nullable)delegate;
- (void)refreshWithUserPermission:(BOOL)enabled;
- (void)stop;
@end
NS_ASSUME_NONNULL_END
