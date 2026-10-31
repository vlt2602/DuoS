#import "DuoSHUDRenderer.h"
#import "../../Shared/DuoSHUDTransport.h"
#import "../../Shared/DuoSCarPlayState.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreFoundation/CoreFoundation.h>
#include <unistd.h>

@interface DuoSHUDRenderer : NSObject
@property(nonatomic, strong) CATextLayer *text;
@property(nonatomic) int token;
@property(nonatomic) DuoSHUDSample last;
@property(nonatomic) BOOL hasSample;
- (void)attach:(UIView *)host;
- (void)detach;
@end

@implementation DuoSHUDRenderer
- (instancetype)init {
    if ((self = [super init])) {
        _token = -1;
        _text = [CATextLayer layer];
        _text.contentsScale = [UIScreen mainScreen].scale;
        _text.alignmentMode = kCAAlignmentCenter;
        _text.fontSize = 20.0;
        _text.foregroundColor = [UIColor whiteColor].CGColor;
        _text.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65].CGColor;
        _text.cornerRadius = 6.0;
        _text.masksToBounds = YES;
        _text.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _token = DuoSHUDSubscribe(dispatch_get_main_queue(), ^(DuoSHUDSample sample) {
            typeof(self) owner = weakSelf;
            if (!owner) return;
            owner.last = sample;
            owner.hasSample = YES;
            [owner refresh];
        });
    }
    return self;
}
- (BOOL)enabled {
    if (access("/var/mobile/Library/Preferences/.duos-disabled", F_OK) == 0) return NO;
    CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR("hudEnabled"),
                                                       CFSTR("com.duos.preferences"));
    BOOL enabled = value && CFGetTypeID(value) == CFBooleanGetTypeID() &&
                   CFBooleanGetValue((CFBooleanRef)value);
    if (value) CFRelease(value);
    return enabled;
}
- (void)refresh {
    if (![NSThread isMainThread]) return;
    if (![self enabled] || !DuoSCarPlayIsVerifiedConnected() || !self.hasSample ||
        !DuoSHUDIsFresh(&_last, (uint32_t)[NSProcessInfo processInfo].systemUptime, 10) ||
        self.last.speed_tenths == 4095 || !self.text.superlayer) {
        self.text.hidden = YES;
        return;
    }
    double kmh = self.last.speed_tenths / 10.0;
    NSString *text = [NSString stringWithFormat:@"%.0f km/h", kmh];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.text.string = text;
    self.text.hidden = NO;
    [CATransaction commit];
}
- (void)attach:(UIView *)host {
    if (!host || ![NSThread isMainThread] || ![self enabled]) return;
    [self.text removeFromSuperlayer];
    self.text.frame = CGRectMake(12, 12, 136, 29);
    [host.layer addSublayer:self.text];
    [self refresh];
}
- (void)detach {
    if (![NSThread isMainThread]) return;
    [self.text removeFromSuperlayer];
    self.text.hidden = YES;
}
- (void)dealloc {
    DuoSHUDUnsubscribe(_token);
}
@end
static DuoSHUDRenderer *gRenderer;
void DuoSAttachHUDToCarPlayView(UIView *view) {
    if (![NSThread isMainThread]) return;
    if (!gRenderer) gRenderer = [DuoSHUDRenderer new];
    [gRenderer attach:view];
}
void DuoSDetachHUD(void) {
    if (![NSThread isMainThread]) return;
    [gRenderer detach];
}
