#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

// HUD nhe: moi thanh phan duoc ve boi CALayer/CATextLayer.
// Khong GPS, khong timer, khong truy cap mang; chi cap nhat khi du lieu doi.
@interface DuoSHUDLayer : CALayer
@property (nonatomic, assign) NSInteger speedKmh;
- (void)updateSpeedKmh:(NSInteger)speedKmh;
@end
