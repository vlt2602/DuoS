#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "../DuoSCore/DuoSGeometry.h"
#import "../Shared/DuoSHUDLayer.h"

// Giao dien xem thu THUC SU trong app, khong co quyen ve len CarPlay.
// Dung CALayer de han che chi phi ve tren iPhone 7.

@interface DuoSRootViewController : UIViewController
@property (nonatomic, strong) UILabel *titleText;
@property (nonatomic, strong) UILabel *subtitleText;
@property (nonatomic, strong) UILabel *displayStatus;
@property (nonatomic, strong) UILabel *disclaimer;
@property (nonatomic, strong) UISegmentedControl *layoutSelector;
@property (nonatomic, strong) CALayer *canvas;
@property (nonatomic, strong) NSArray<CALayer *> *panes;
@property (nonatomic, strong) DuoSHUDLayer *hud;
@end

@implementation DuoSRootViewController

- (UILabel *)label:(NSString *)value font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = value;
    label.font = font;
    label.textColor = color;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    return label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.10 blue:0.17 alpha:1];
    self.titleText = [self label:@"DuoS" font:[UIFont boldSystemFontOfSize:34]
                             color:UIColor.whiteColor];
    self.subtitleText = [self label:@"BỐ CỤC & HUD — BẢN THỬ NGHIỆM"
                                 font:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]
                                color:[UIColor colorWithRed:0.41 green:0.85 blue:0.76 alpha:1]];
    self.displayStatus = [self label:@"" font:[UIFont systemFontOfSize:14]
                                color:UIColor.whiteColor];
    self.disclaimer = [self label:@"Chỉ mô phỏng giao diện trên iPhone.\nKhông mở ứng dụng thứ hai trên CarPlay."
                             font:[UIFont systemFontOfSize:13]
                            color:[UIColor colorWithWhite:0.69 alpha:1]];

    self.layoutSelector = [[UISegmentedControl alloc] initWithItems:@[@"50/50", @"65/35", @"1 + 2"]];
    self.layoutSelector.selectedSegmentIndex = 0;
    self.layoutSelector.selectedSegmentTintColor = [UIColor colorWithRed:0.20 green:0.77 blue:0.66 alpha:1];
    [self.layoutSelector addTarget:self action:@selector(updateLayout)
                   forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.layoutSelector];

    self.canvas = [CALayer layer];
    self.canvas.backgroundColor = [UIColor colorWithRed:0.11 green:0.15 blue:0.22 alpha:1].CGColor;
    self.canvas.cornerRadius = 12.0;
    self.canvas.masksToBounds = YES;
    [self.view.layer addSublayer:self.canvas];

    NSMutableArray *arr = [NSMutableArray array];
    NSArray<NSString *> *names = @[@"A", @"B", @"C"];
    NSArray<UIColor *> *colors = @[
        [UIColor colorWithRed:0.13 green:0.38 blue:0.62 alpha:1],
        [UIColor colorWithRed:0.12 green:0.48 blue:0.41 alpha:1],
        [UIColor colorWithRed:0.36 green:0.33 blue:0.63 alpha:1]
    ];
    for (NSUInteger i = 0; i < 3; i++) {
        CALayer *pane = [CALayer layer];
        pane.backgroundColor = colors[i].CGColor;
        [self.canvas addSublayer:pane];
        CATextLayer *text = [CATextLayer layer];
        text.name = @"duos.title";
        text.string = names[i];
        text.alignmentMode = kCAAlignmentCenter;
        text.fontSize = 29.0;
        text.foregroundColor = UIColor.whiteColor.CGColor;
        text.contentsScale = [UIScreen mainScreen].scale;
        [pane addSublayer:text];
        [arr addObject:pane];
    }
    self.panes = arr;

    self.hud = [DuoSHUDLayer layer];
    self.hud.speedKmh = 88; // DU LIEU MAU - KHONG CO GPS
    [self.canvas addSublayer:self.hud];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenChanged:)
                       name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenChanged:)
                       name:UIScreenDidDisconnectNotification object:nil];
    [self refreshScreenStatus];
}

- (void)screenChanged:(__unused NSNotification *)notice {
    [self refreshScreenStatus];
}

- (void)refreshScreenStatus {
    // Day chi la trang thai UIScreen, khong phai xac nhan phien CarPlay.
    BOOL external = [UIScreen screens].count > 1;
    self.displayStatus.text = external ? @"Màn hình ngoài: Đang kết nối (chưa xác nhận CarPlay)" :
                                        @"Màn hình ngoài: Chưa phát hiện";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat top = self.view.safeAreaInsets.top + 18;
    CGFloat footerHeight = 65;
    self.titleText.frame = CGRectMake(16, top, width - 32, 48);
    self.subtitleText.frame = CGRectMake(16, top + 49, width - 32, 25);
    self.displayStatus.frame = CGRectMake(16, top + 90, width - 32, 44);
    self.layoutSelector.frame = CGRectMake(24, top + 149, width - 48, 34);
    CGFloat cw = MIN(MAX(0.0, width - 30), 520.0);
    CGFloat ch = cw * 0.60;
    self.canvas.frame = CGRectMake((width - cw) * 0.5, top + 202, cw, ch);
    self.disclaimer.frame = CGRectMake(14, top + 202 + ch + 18,
                                       width - 28, footerHeight);
    [self updateLayout];
}

- (void)updateLayout {
    // Kich thuoc tham chieu 800x480; luc ve thu nho theo kich thuoc iPhone.
    const NSInteger choice = self.layoutSelector.selectedSegmentIndex;
    const float fraction = (choice == 1) ? 0.65f : 0.5f;
    DuoSPaneFrames f;
    if (!DuoSComputeTwoPanes((DuoSRect){0, 0, 800, 480}, fraction, 8, &f)) {
        for (CALayer *p in self.panes) p.hidden = YES;
        return;
    }
    const CGFloat scale = CGRectGetWidth(self.canvas.bounds) / 800.0;
    CGRect r[3] = {
        CGRectMake(f.left.x, f.left.y, f.left.width, f.left.height),
        CGRectMake(f.right.x, f.right.y, f.right.width, f.right.height),
        CGRectZero
    };
    if (choice == 2) {
        // 1 vung lon 50%, hai vung nho chia tren/duoi, cach nhau 8 diem.
        r[1] = CGRectMake(f.right.x, 0, f.right.width, 236);
        r[2] = CGRectMake(f.right.x, 244, f.right.width, 236);
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (NSUInteger i = 0; i < self.panes.count; i++) {
        CALayer *pane = self.panes[i];
        pane.hidden = (i == 2 && choice != 2);
        CGRect v = r[i];
        pane.frame = CGRectMake(v.origin.x * scale, v.origin.y * scale,
                                v.size.width * scale, v.size.height * scale);
        for (CALayer *label in pane.sublayers) {
            if ([label.name isEqualToString:@"duos.title"]) {
                label.frame = CGRectMake(0, (pane.bounds.size.height - 36) * .5,
                                         pane.bounds.size.width, 36);
            }
        }
    }
    // Vi tri HUD chi la minh hoa. Khong co widget nao tren CarPlay.
    CGFloat hw = MIN(92.0, 140.0 * scale);
    self.hud.frame = CGRectMake(MAX(0, self.canvas.bounds.size.width - hw - 8),
                                8, hw, MIN(110.0, 170.0 * scale));
    [CATransaction commit];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
