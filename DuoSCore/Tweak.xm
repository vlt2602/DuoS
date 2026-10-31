#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// DuoS Core Foundation (v0.2 preview).
// Giai doan nay CHI quan sat man hinh ngoai va luu bo cuc trong bo nho.
// Chua hook SpringBoard, FBScene, CarPlay hay chuyen tiep su kien cham.

typedef NS_ENUM(NSInteger, DuoSLayoutMode) {
    DuoSLayoutModeEqual = 0,   // Hai vung 50/50
    DuoSLayoutModeWideLeft = 1 // Vung trai 65%, phai 35%
};

@interface DuoSCoreState : NSObject
@property (nonatomic, assign, readonly) BOOL externalDisplayConnected;
@property (nonatomic, assign, readonly) DuoSLayoutMode layoutMode;
@property (nonatomic, assign, readonly) CGFloat splitFraction;
+ (instancetype)shared;
- (void)selectLayout:(DuoSLayoutMode)layout;
@end

@interface DuoSCoreState ()
@property (nonatomic, assign, readwrite) BOOL externalDisplayConnected;
@property (nonatomic, assign, readwrite) DuoSLayoutMode layoutMode;
@property (nonatomic, assign, readwrite) CGFloat splitFraction;
@end

@implementation DuoSCoreState {
    id _screenConnectedObserver;
    id _screenDisconnectedObserver;
}

+ (instancetype)shared {
    static DuoSCoreState *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _layoutMode = DuoSLayoutModeEqual;
    _splitFraction = 0.5;
    return self;
}

- (void)selectLayout:(DuoSLayoutMode)layout {
    // Du lieu nhap ngoai pham vi se quay ve bo cuc an toan.
    if (layout != DuoSLayoutModeEqual && layout != DuoSLayoutModeWideLeft) {
        layout = DuoSLayoutModeEqual;
    }
    @synchronized (self) {
        _layoutMode = layout;
        _splitFraction = (layout == DuoSLayoutModeWideLeft) ? 0.65 : 0.5;
    }
}

// UIScreen thong bao man hinh ngoai, KHONG xac nhan do la CarPlay.
// Cap nhat tren main queue, khong polling / khong timer.
- (void)refreshExternalDisplayState {
    NSAssert([NSThread isMainThread], @"DuoS state must update on main thread");
    BOOL present = ([UIScreen screens].count > 1);
    if (_externalDisplayConnected == present) return;
    _externalDisplayConnected = present;
    NSLog(@"[DuoS] External display %@", present ? @"connected" : @"disconnected");
}

- (void)startObserving {
    NSAssert([NSThread isMainThread], @"Must start on main thread");
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

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (_screenConnectedObserver) [center removeObserver:_screenConnectedObserver];
    if (_screenDisconnectedObserver) [center removeObserver:_screenDisconnectedObserver];
}
@end

%ctor {
    @autoreleasepool {
        // Khong hook method he thong. Khoi tao thue bao quan sat thu dong.
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DuoSCoreState shared] startObserving];
        });
    }
}
