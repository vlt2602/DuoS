#import "DuoSHUDLayer.h"
#import <UIKit/UIKit.h>
#import <math.h>

@interface DuoSHUDLayer ()
@property (nonatomic, strong) CATextLayer *speedText;
@property (nonatomic, strong) CATextLayer *unitText;
@property (nonatomic, strong) CAShapeLayer *circle;
@end

@implementation DuoSHUDLayer

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.backgroundColor = [UIColor colorWithRed:0.07 green:0.12 blue:0.18 alpha:0.94].CGColor;
    self.cornerRadius = 18.0;
    self.masksToBounds = YES;
    self.speedKmh = -1;

    _circle = [CAShapeLayer layer];
    _circle.fillColor = UIColor.clearColor.CGColor;
    _circle.strokeColor = [UIColor colorWithRed:0.18 green:0.77 blue:0.71 alpha:1].CGColor;
    _circle.lineWidth = 5.0;
    [self addSublayer:_circle];

    _speedText = [CATextLayer layer];
    _speedText.contentsScale = [UIScreen mainScreen].scale;
    _speedText.alignmentMode = kCAAlignmentCenter;
    _speedText.foregroundColor = UIColor.whiteColor.CGColor;
    _speedText.fontSize = 54.0;
    _speedText.string = @"--";
    [self addSublayer:_speedText];

    _unitText = [CATextLayer layer];
    _unitText.contentsScale = [UIScreen mainScreen].scale;
    _unitText.alignmentMode = kCAAlignmentCenter;
    _unitText.foregroundColor = [UIColor colorWithWhite:0.78 alpha:1].CGColor;
    _unitText.fontSize = 14.0;
    _unitText.string = @"km/h";
    [self addSublayer:_unitText];
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat diameter = MIN(w - 32.0, h - 20.0);
    diameter = MAX(0.0, diameter);
    CGRect ring = CGRectMake((w - diameter) / 2.0, (h - diameter) / 2.0,
                             diameter, diameter);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _circle.frame = self.bounds;
    _circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(ring, 3, 3)].CGPath;
    _speedText.frame = CGRectMake(0.0, h / 2.0 - 42.0, w, 66.0);
    _unitText.frame = CGRectMake(0.0, h / 2.0 + 25.0, w, 24.0);
    [CATransaction commit];
}

- (void)setSpeedKmh:(NSInteger)speedKmh {
    [self updateSpeedKmh:speedKmh];
}

- (void)updateSpeedKmh:(NSInteger)speedKmh {
    // Gia tri am hoac qua 999 la du lieu khong hop le.
    // Giup HUD khong hien thi mot con so GPS sai.
    NSInteger safeSpeed = (speedKmh >= 0 && speedKmh <= 999) ? speedKmh : -1;
    if (_speedKmh == safeSpeed) return;
    _speedKmh = safeSpeed;
    NSString *value = (safeSpeed < 0) ? @"--" :
                      [NSString stringWithFormat:@"%ld", (long)safeSpeed];
    if ([NSThread isMainThread]) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.speedText.string = value;
        [CATransaction commit];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.speedText.string = value;
            [CATransaction commit];
        });
    }
}
@end
