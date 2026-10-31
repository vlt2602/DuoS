#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Chuyen GPS -> km/h thuc, CHI khi nguoi dung bam bat trong app iPhone.
// Khong giu GPS khi ung dung vao nen; khong luu/toa do, khong gui mang.
@protocol DuoSSpeedProviderDelegate <NSObject>
- (void)duosSpeedChanged:(NSInteger)kmh detail:(NSString *)detail;
@end

@interface DuoSSpeedProvider : NSObject <CLLocationManagerDelegate>
@property (nonatomic, weak) id<DuoSSpeedProviderDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL active;
- (void)startWithUserAction;
- (void)stop;
@end
