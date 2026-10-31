#import "DuoSLayoutPreviewController.h"
#import "../DuoSCore/DuoSGeometry.h"
#import <QuartzCore/QuartzCore.h>

@interface DuoSLayoutPreviewController ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) CALayer *canvasLayer;
@property (nonatomic, strong) CALayer *leftPane;
@property (nonatomic, strong) CALayer *rightPane;
@end

@implementation DuoSLayoutPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bố cục - Xem thử";
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    self.segmentedControl = [[UISegmentedControl alloc]
        initWithItems:@[@"50 / 50", @"65 / 35"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self
                              action:@selector(layoutChanged:)
                    forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];

    CALayer *canvas = [CALayer layer];
    canvas.backgroundColor = UIColor.blackColor.CGColor;
    canvas.cornerRadius = 10;
    canvas.masksToBounds = YES;
    [self.view.layer addSublayer:canvas];
    self.canvasLayer = canvas;

    CALayer *left = [CALayer layer];
    left.backgroundColor = [UIColor colorWithRed:0.16 green:0.37 blue:0.55 alpha:1].CGColor;
    [canvas addSublayer:left];
    self.leftPane = left;

    CALayer *right = [CALayer layer];
    right.backgroundColor = [UIColor colorWithRed:0.12 green:0.48 blue:0.41 alpha:1].CGColor;
    [canvas addSublayer:right];
    self.rightPane = right;

    [self addTitle:@"A" toPane:left];
    [self addTitle:@"B" toPane:right];
}

- (void)addTitle:(NSString *)title toPane:(CALayer *)pane {
    CATextLayer *text = [CATextLayer layer];
    text.name = @"duos.preview.title";
    text.string = title;
    text.alignmentMode = kCAAlignmentCenter;
    text.fontSize = 24.0;
    text.contentsScale = UIScreen.mainScreen.scale;
    text.foregroundColor = UIColor.whiteColor.CGColor;
    [pane addSublayer:text];
}

- (void)layoutChanged:(__unused UISegmentedControl *)control {
    [self updatePreview];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat y = self.view.safeAreaInsets.top + 28.0;
    self.segmentedControl.frame = CGRectMake(20, y, MAX(0, width - 40), 36);
    CGFloat displayWidth = MIN(MAX(0, width - 40), 520.0);
    CGFloat displayHeight = displayWidth * 0.60; // Ty le CarPlay mo phong 800x480.
    self.canvasLayer.frame = CGRectMake((width - displayWidth)/2.0,
                                         y + 66, displayWidth, displayHeight);
    [self updatePreview];
}

- (void)updatePreview {
    DuoSPaneFrames frames;
    float fraction = self.segmentedControl.selectedSegmentIndex == 1 ? 0.65f : 0.50f;
    // Phai tinh tren khung ao 800x480 de giu cac rang buoc toi thieu 120 diem.
    if (!DuoSComputeTwoPanes((DuoSRect){0,0,800,480}, fraction, 8, &frames)) {
        self.leftPane.hidden = YES;
        self.rightPane.hidden = YES;
        return;
    }
    self.leftPane.hidden = NO;
    self.rightPane.hidden = NO;

    CGFloat ratio = CGRectGetWidth(self.canvasLayer.bounds) / 800.0;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.leftPane.frame = CGRectMake(frames.left.x * ratio,
                                     frames.left.y * ratio,
                                     frames.left.width * ratio,
                                     frames.left.height * ratio);
    self.rightPane.frame = CGRectMake(frames.right.x * ratio,
                                      frames.right.y * ratio,
                                      frames.right.width * ratio,
                                      frames.right.height * ratio);
    for (CALayer *pane in @[self.leftPane, self.rightPane]) {
        for (CALayer *child in pane.sublayers) {
            if ([child.name isEqualToString:@"duos.preview.title"]) {
                child.frame = CGRectMake(0, (pane.bounds.size.height - 30)/2.0,
                                         pane.bounds.size.width, 32);
            }
        }
    }
    [CATransaction commit];
}
@end
