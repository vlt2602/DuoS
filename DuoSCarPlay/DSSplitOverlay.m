#import "DSSplitOverlay.h"
#import "DSAppCatalog.h"

@class DSSplitOverlay;
@interface DSOverlayRoot : UIView
@property(nonatomic,weak) DSSplitOverlay *owner;
@property(nonatomic,weak) UIButton *bubble;
@property(nonatomic,weak) UIView *panel;
@end
@interface DSSplitOverlay ()
@property(nonatomic,strong) DSOverlayRoot *root;
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UIView *leftCard;
@property(nonatomic,strong) UIView *rightCard;
@property(nonatomic,strong) UILabel *leftInfo;
@property(nonatomic,strong) UILabel *rightInfo;
@property(nonatomic,strong) UILabel *notice;
@property(nonatomic,strong) UILabel *chooserTitle;
@property(nonatomic,strong) UIView *chooser;
@property(nonatomic,strong) UISegmentedControl *ratio;
@property(nonatomic,strong) NSMutableArray<NSString *> *selectedIDs;
@property(nonatomic,strong) NSMutableArray<NSString *> *selectedNames;
@property(nonatomic,strong) NSArray<NSDictionary<NSString *,NSString *> *> *installed;
@property(nonatomic,weak) UIWindow *window;
@property(nonatomic) NSUInteger targetPane;
@property(nonatomic) BOOL layoutVisible;
- (void)layoutElements;
@end

@implementation DSOverlayRoot
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.owner layoutElements];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden || self.alpha <= 0.01 || !self.userInteractionEnabled) return nil;
    if (self.panel && !self.panel.hidden &&
        CGRectContainsPoint(self.panel.frame, point)) return [super hitTest:point withEvent:event];
    if (self.bubble && !self.bubble.hidden &&
        CGRectContainsPoint(self.bubble.frame, point)) return [super hitTest:point withEvent:event];
    return nil;  /* No interference with normal CarPlay outside the UI. */
}
@end

@implementation DSSplitOverlay
- (instancetype)init {
    if ((self = [super init])) {
        _selectedIDs = [NSMutableArray arrayWithObjects:@"", @"", nil];
        _selectedNames = [NSMutableArray arrayWithObjects:@"", @"", nil];
        _targetPane = 0;
        _installed = @[];
    }
    return self;
}
- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)selector container:(UIView *)parent {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    b.titleLabel.numberOfLines = 2;
    b.titleLabel.textAlignment = NSTextAlignmentCenter;
    b.tintColor = UIColor.whiteColor;
    b.backgroundColor = [UIColor colorWithRed:.12 green:.22 blue:.33 alpha:1];
    b.layer.cornerRadius = 10;
    [b addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [parent addSubview:b];
    return b;
}
- (void)attachToWindow:(UIWindow *)window {
    if (!window || ![NSThread isMainThread]) return;
    if (self.root.superview == window) { [self refresh]; return; }
    [self detach];
    self.window = window;
    self.root = [[DSOverlayRoot alloc] initWithFrame:window.bounds];
    self.root.backgroundColor = UIColor.clearColor;
    self.root.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.root.owner = self;
    [window addSubview:self.root];

    self.bubble = [self buttonWithTitle:@"◫\nDuoS" action:@selector(bubbleTapped)
                            container:self.root];
    self.bubble.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    self.bubble.layer.cornerRadius = 23;
    self.bubble.backgroundColor = [UIColor colorWithRed:.03 green:.46 blue:.65 alpha:.92];
    self.root.bubble = self.bubble;

    self.panel = [[UIView alloc] initWithFrame:CGRectZero];
    self.panel.backgroundColor = [UIColor colorWithRed:.035 green:.07 blue:.12 alpha:.97];
    self.panel.layer.cornerRadius = 14;
    self.panel.layer.masksToBounds = YES;
    self.panel.hidden = YES;
    [self.root addSubview:self.panel];
    self.root.panel = self.panel;
    self.notice = [UILabel new];
    self.notice.text = @"Bố cục thử nghiệm — chưa phát hình ứng dụng";
    self.notice.textColor = [UIColor colorWithWhite:.80 alpha:1];
    self.notice.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    self.notice.textAlignment = NSTextAlignmentCenter;
    [self.panel addSubview:self.notice];

    UIButton *close = [self buttonWithTitle:@"Đóng" action:@selector(closeTapped)
                                  container:self.panel];
    close.tag = 600;
    self.ratio = [[UISegmentedControl alloc] initWithItems:@[@"50/50", @"60/40", @"40/60"]];
    self.ratio.selectedSegmentIndex = 0;
    [self.ratio addTarget:self action:@selector(ratioChanged)
         forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:self.ratio];

    self.leftCard = [self cardWithTitle:@"Ô TRÁI" pane:0];
    self.rightCard = [self cardWithTitle:@"Ô PHẢI" pane:1];
    [self.panel addSubview:self.leftCard];
    [self.panel addSubview:self.rightCard];

    self.chooser = [UIView new];
    self.chooser.backgroundColor = [UIColor colorWithRed:.07 green:.13 blue:.22 alpha:1];
    self.chooser.layer.cornerRadius = 10;
    self.chooser.hidden = YES;
    [self.panel addSubview:self.chooser];
    self.chooserTitle = [UILabel new];
    self.chooserTitle.textColor = UIColor.whiteColor;
    self.chooserTitle.font = [UIFont boldSystemFontOfSize:16];
    self.chooserTitle.textAlignment = NSTextAlignmentCenter;
    [self.chooser addSubview:self.chooserTitle];
    [self buttonWithTitle:@"Quay lại" action:@selector(closePicker) container:self.chooser].tag = 700;
    [self refresh];
    [self layoutElements];
}
- (UIView *)cardWithTitle:(NSString *)name pane:(NSUInteger)pane {
    UIView *card = [UIView new];
    card.backgroundColor = [UIColor colorWithRed:.11 green:.17 blue:.24 alpha:1];
    card.layer.cornerRadius = 9;
    UILabel *title = [UILabel new];
    title.text = name;
    title.font = [UIFont boldSystemFontOfSize:13];
    title.textColor = [UIColor colorWithWhite:.75 alpha:1];
    title.textAlignment = NSTextAlignmentCenter;
    title.tag = 100;
    [card addSubview:title];
    UILabel *info = [UILabel new];
    info.textColor = UIColor.whiteColor;
    info.textAlignment = NSTextAlignmentCenter;
    info.numberOfLines = 4;
    info.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    info.tag = 101;
    [card addSubview:info];
    if (pane == 0) self.leftInfo = info;
    else self.rightInfo = info;
    UIButton *choose = [self buttonWithTitle:@"Chọn ứng dụng"
                                      action:@selector(choosePane:) container:card];
    choose.tag = 200 + (NSInteger)pane;
    [self updateCardLabel:pane];
    return card;
}
- (void)updateCardLabel:(NSUInteger)pane {
    if (pane >= 2) return;
    UILabel *info = pane == 0 ? self.leftInfo : self.rightInfo;
    NSString *name = self.selectedNames[pane];
    info.text = name.length
        ? [NSString stringWithFormat:@"%@\nChưa có Scene trực tiếp", name]
        : @"Chưa chọn ứng dụng";
}
- (void)refresh {
    if (![NSThread isMainThread]) return;
    if (!self.root) return;
    if (self.layoutVisible && !self.panel.hidden && !self.chooser.hidden)
        [self buildPicker];
    [self updateCardLabel:0];
    [self updateCardLabel:1];
}
- (void)bubbleTapped {
    self.layoutVisible = !self.layoutVisible;
    self.panel.hidden = !self.layoutVisible;
    self.chooser.hidden = YES;
    [self layoutElements];
}
- (void)closeTapped {
    self.layoutVisible = NO;
    self.panel.hidden = YES;
    self.chooser.hidden = YES;
}
- (void)ratioChanged { [self layoutElements]; }
- (void)choosePane:(UIButton *)sender {
    self.targetPane = sender.tag == 201 ? 1 : 0;
    self.chooser.hidden = NO;
    [self buildPicker];
}
- (void)closePicker { self.chooser.hidden = YES; }
- (void)pickApp:(UIButton *)sender {
    NSInteger i = sender.tag - 800;
    if (i < 0 || i >= (NSInteger)self.installed.count || self.targetPane >= 2) return;
    NSDictionary *app = self.installed[(NSUInteger)i];
    self.selectedIDs[self.targetPane] = app[@"id"];
    self.selectedNames[self.targetPane] = app[@"name"];
    [self updateCardLabel:self.targetPane];
    [self closePicker];
}
- (void)buildPicker {
    /* Query LaunchServices on every opening, not on the 20-second heartbeat. */
    self.installed = [DSAppCatalog installedCandidates];
    self.chooserTitle.text = [NSString stringWithFormat:@"ỨNG DỤNG ĐÃ CÀI — Ô %@",
                               self.targetPane == 0 ? @"TRÁI" : @"PHẢI"];
    for (UIView *v in [self.chooser.subviews copy]) {
        if (v.tag >= 800 || v.tag == 790) [v removeFromSuperview];
    }
    if (self.installed.count == 0) {
        UILabel *msg = [UILabel new];
        msg.tag = 790;
        msg.text = @"Không tìm thấy Waze, VietMap Live, GOFA hoặc WYN đã cài trên iPhone.";
        msg.font = [UIFont systemFontOfSize:14];
        msg.textColor = UIColor.whiteColor;
        msg.textAlignment = NSTextAlignmentCenter;
        msg.numberOfLines = 3;
        [self.chooser addSubview:msg];
    } else {
        for (NSUInteger i = 0; i < self.installed.count; i++) {
            UIButton *b = [self buttonWithTitle:self.installed[i][@"name"]
                                         action:@selector(pickApp:) container:self.chooser];
            b.tag = 800 + (NSInteger)i;
        }
    }
    [self layoutElements];
}
- (void)layoutCard:(UIView *)card {
    CGFloat w = card.bounds.size.width, h = card.bounds.size.height;
    [card viewWithTag:100].frame = CGRectMake(5, 8, MAX(0,w-10), 22);
    [card viewWithTag:101].frame = CGRectMake(5, 34, MAX(0,w-10), MAX(0,h-83));
    [card viewWithTag:200].frame = CGRectZero; // The correct pane button is laid out below.
    UIView *a = [card viewWithTag:200];
    UIView *b = [card viewWithTag:201];
    if (a) a.frame = CGRectMake(8, MAX(35,h-43), MAX(0,w-16), 34);
    if (b) b.frame = CGRectMake(8, MAX(35,h-43), MAX(0,w-16), 34);
}
- (void)layoutElements {
    if (!self.root) return;
    CGRect bounds = self.root.bounds;
    CGFloat w = CGRectGetWidth(bounds), h = CGRectGetHeight(bounds);
    self.bubble.frame = CGRectMake(MAX(4,w-54), MAX(40,h*0.52-23), 46, 46);
    CGFloat inset = 12;
    self.panel.frame = CGRectMake(inset, MAX(4,h*0.07), MAX(0,w-2*inset),
                    MAX(0,h-MAX(4,h*0.07)*2));
    CGFloat pw = CGRectGetWidth(self.panel.bounds), ph = CGRectGetHeight(self.panel.bounds);
    [self.panel viewWithTag:600].frame = CGRectMake(MAX(0,pw-78), 9, 68, 30);
    self.notice.frame = CGRectMake(8, 8, MAX(0,pw-92), 33);
    self.ratio.frame = CGRectMake(MAX(12,(pw-238)*.5), 43, MIN(238,pw-24), 30);
    CGFloat usable = MAX(0,pw-24), contentY = 82, contentH = MAX(0,ph-95);
    CGFloat gutter = 8, total = MAX(0,usable-gutter);
    CGFloat fraction = self.ratio.selectedSegmentIndex == 1 ? 0.6 :
                       self.ratio.selectedSegmentIndex == 2 ? 0.4 : 0.5;
    CGFloat leftWidth = floor(total*fraction);
    self.leftCard.frame = CGRectMake(12,contentY,leftWidth,contentH);
    self.rightCard.frame = CGRectMake(12+leftWidth+gutter,contentY,total-leftWidth,contentH);
    [self layoutCard:self.leftCard];
    [self layoutCard:self.rightCard];
    self.chooser.frame = CGRectInset(self.panel.bounds, 7, 7);
    CGFloat mw = CGRectGetWidth(self.chooser.bounds), mh = CGRectGetHeight(self.chooser.bounds);
    self.chooserTitle.frame = CGRectMake(8,12,MAX(0,mw-16),35);
    UIView *back = [self.chooser viewWithTag:700];
    back.frame = CGRectMake(MAX(8,mw-112), MAX(48,mh-47), 102, 37);
    CGFloat rowY = 55;
    for (NSUInteger i = 0; i < self.installed.count; i++) {
        UIView *v = [self.chooser viewWithTag:800+(NSInteger)i];
        v.frame = CGRectMake(12,rowY + i*49,MAX(0,mw-24),42);
    }
    UIView *message = [self.chooser viewWithTag:790];
    message.frame = CGRectMake(12,60,MAX(0,mw-24),90);
}
- (void)detach {
    [self.root removeFromSuperview];
    self.root = nil;
    self.bubble = nil;
    self.panel = nil;
    self.chooser = nil;
    self.leftCard = nil;
    self.rightCard = nil;
    self.leftInfo = nil;
    self.rightInfo = nil;
    self.window = nil;
    self.layoutVisible = NO;
}
@end
