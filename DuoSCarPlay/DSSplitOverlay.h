#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/**
 * A parked-only two-pane layout and four-app picker.
 * This is NOT a live iOS app scene host. Scene hosting remains disabled until
 * the private iOS 15.8.8 Scene APIs are validated on actual hardware.
 */
@interface DSSplitOverlay : NSObject
- (void)attachToWindow:(UIWindow *)window;
- (void)detach;
- (void)refresh;
@end
NS_ASSUME_NONNULL_END
