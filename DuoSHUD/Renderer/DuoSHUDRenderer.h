#import <UIKit/UIKit.h>
/* Attaches ONLY to a caller-provided, verified CarPlay content view.
 * DuoS does not guess which SpringBoard window belongs to CarPlay. */
FOUNDATION_EXPORT void DuoSAttachHUDToCarPlayView(UIView *view);
FOUNDATION_EXPORT void DuoSDetachHUD(void);
