#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../DuoSHUD/Renderer/DuoSHUDRenderer.h"
#import "../Shared/DuoSCarPlayState.h"
#import "../Shared/DuoSTouchMapper.h"
#import <CoreFoundation/CoreFoundation.h>
#include <unistd.h>
#include <fcntl.h>

/*
 * Only loaded in com.apple.CarPlayApp (DashBoard/CarPlay process).
 * Passively observes UIKit window activity; NO private Scene hooks.
 * Diagnostic overlay is disabled by default; transparent to touches.
 *
 * Runtime check: without an active CarPlayApp window, reports disconnected.
 * This is a *process/window heuristic*, not an authenticated vehicle signal.
 * iOS 15.8.8 must be validated on a real device while PARKED.
 */

static BOOL DSFlag(NSString *name) {
    CFPreferencesAppSynchronize(CFSTR("com.duos.preferences"));
    CFPropertyListRef v = CFPreferencesCopyAppValue((__bridge CFStringRef)name,
                                                    CFSTR("com.duos.preferences"));
    BOOL b = v && CFGetTypeID(v) == CFBooleanGetTypeID() &&
             CFBooleanGetValue((CFBooleanRef)v);
    if (v) CFRelease(v);
    return b;
}

static BOOL DSDisabled(void) {
    return access("/var/mobile/Library/Preferences/.duos-disabled", F_OK) == 0;
}
static void DSLog(NSString *message) {
    static NSString *lastLog;
    if ([lastLog isEqualToString:message]) return;
    lastLog = [message copy];
    NSString *line = [NSString stringWithFormat:@"uptime=%.0f CarPlayApp %@\n",
             [NSProcessInfo processInfo].systemUptime, message];
    int fd = open("/var/mobile/Library/Preferences/com.duos.carplay.log",
                  O_WRONLY | O_CREAT | O_APPEND | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (fd < 0) return;
    NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length) (void)write(fd, data.bytes, data.length);
    close(fd);
}

@interface DSTouchCalibrationView : UIView
@property(nonatomic,strong) UILabel *note;
@end
@implementation DSTouchCalibrationView
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.13];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _note = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 500, 95)];
        _note.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.85];
        _note.textColor = UIColor.whiteColor;
        _note.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        _note.numberOfLines = 3;
        _note.text = @"DUOS - CHẾ ĐỘ ĐO CẢM ỨNG\nChỉ thử khi xe đang đỗ\nTắt trong Cài đặt iPhone để trở về CarPlay";
        [self addSubview:_note];
    }
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (!touch) return;
    CGPoint p = [touch locationInView:self];
    UIEdgeInsets insets = self.safeAreaInsets;
    CGRect content = UIEdgeInsetsInsetRect(self.bounds, insets);
    DuoSPoint output;
    BOOL valid = DuoSTouchMap((DuoSPoint){p.x, p.y},
             (DuoSRect){content.origin.x,content.origin.y,content.size.width,content.size.height},
             (DuoSRect){0,0,1000,1000},DUOS_ROT_0,&output);
    if (valid) {
        self.note.text = [NSString stringWithFormat:
           @"DUOS - ĐO CẢM ỨNG (XE ĐANG ĐỖ)\nX: %.0f/1000 | Y: %.0f/1000\nTắt chế độ này trên iPhone",output.x,output.y];
    } else {
        self.note.text = @"Điểm chạm nằm ngoài vùng hiển thị hợp lệ";
    }
    (void)event;
}
@end

@interface DSCarPlayBridge : NSObject
@property(nonatomic,strong) UILabel *status;
@property(nonatomic,strong) DSTouchCalibrationView *calibration;
@property(nonatomic,weak) UIWindow *currentWindow;
@property(nonatomic,strong) dispatch_source_t heartbeat;
@property(nonatomic) BOOL lastActive;
- (void)refresh;
@end
@implementation DSCarPlayBridge
- (void)start {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    for (NSString *event in @[UIApplicationDidBecomeActiveNotification,
                              UIApplicationDidEnterBackgroundNotification,
                              UIWindowDidBecomeVisibleNotification,
                              UIWindowDidBecomeHiddenNotification,
                              UIScreenDidConnectNotification,
                              UIScreenDidDisconnectNotification]) {
        [center addObserver:self selector:@selector(refreshNotification:)
                      name:event object:nil];
    }
    [self refresh];
    /* At most 1 wakeup / 20 sec to expire a stale connection after unplug.
     * No disk write on heartbeat unless active state actually changes. */
    dispatch_queue_t q = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0,q);
    self.heartbeat = timer;
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_timer(timer,dispatch_time(DISPATCH_TIME_NOW, 20*NSEC_PER_SEC),
                              20*NSEC_PER_SEC, 3*NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer,^{ [weakSelf refresh]; });
    dispatch_resume(timer);
}
- (void)refreshNotification:(NSNotification *)note {
    (void)note;
    dispatch_async(dispatch_get_main_queue(), ^{ [self refresh]; });
}
- (UIWindow *)carWindow {
    UIApplication *app = UIApplication.sharedApplication;
    if (!app || app.applicationState != UIApplicationStateActive) return nil;
    NSArray<UIWindow *> *windows = app.windows;
    for (UIWindow *w in windows.reverseObjectEnumerator) {
        if (![w isKindOfClass:UIWindow.class] || w.hidden || w.alpha < .1 ||
            w.bounds.size.width <= 0 || w.bounds.size.height <= 0) continue;
        return w;
    }
    return nil;
}
- (void)removeUI {
    [self.status removeFromSuperview];
    [self.calibration removeFromSuperview];
    DuoSDetachHUD();
    self.currentWindow = nil;
}
- (void)refresh {
    if (![NSThread isMainThread]) return;
    if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.CarPlayApp"]) return;
    UIWindow *window = DSDisabled() ? nil : [self carWindow];
    BOOL connected = window != nil;
    /* This is a CarPlayApp activity signal, NOT a cryptographically verified link. */
    DuoSCarPlayPublishVerified(connected);
    if (connected != self.lastActive) {
        DSLog(connected ? @"Cửa sổ CarPlayApp đang hoạt động" :
                            @"Không còn cửa sổ CarPlayApp hoạt động");
        self.lastActive = connected;
    }
    if (!connected) { [self removeUI]; return; }
    BOOL showStatus = DSFlag(@"statusOverlayEnabled");
    BOOL calibration = DSFlag(@"calibrationEnabled");
    BOOL hud = DSFlag(@"hudEnabled");
    if (self.currentWindow != window) {
        [self removeUI];
        self.currentWindow = window;
    }
    if (showStatus && !calibration) {
        if (!self.status) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14,56,220,30)];
            label.text = @"DuoS: CarPlay đang hoạt động";
            label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
            label.textColor = UIColor.whiteColor;
            label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.75];
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.cornerRadius = 6;
            label.clipsToBounds = YES;
            self.status = label;
        }
        if (self.status.superview != window) [window addSubview:self.status];
    } else [self.status removeFromSuperview];

    if (calibration) {
        DuoSDetachHUD();
        if (!self.calibration || self.calibration.superview != window) {
            [self.calibration removeFromSuperview];
            self.calibration = [[DSTouchCalibrationView alloc] initWithFrame:window.bounds];
            [window addSubview:self.calibration];
        }
    } else {
        [self.calibration removeFromSuperview];
        self.calibration = nil;
        if (hud) DuoSAttachHUDToCarPlayView(window);
        else DuoSDetachHUD();
    }
}
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    if (self.heartbeat) dispatch_source_cancel(self.heartbeat);
    [self removeUI];
}
@end

%ctor {
    @autoreleasepool {
        if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.CarPlayApp"]) return;
        if (DSDisabled()) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            static DSCarPlayBridge *bridge;
            if (!bridge) {
                bridge = [DSCarPlayBridge new];
                [bridge start];
            }
        });
    }
}
