#import <Foundation/Foundation.h>
#import "DuoSHUDRenderer.h"

/* A verified CarPlay host must call DuoSAttachHUDToCarPlayView().
 * No unverified window injection or high-frequency timer. */
%ctor {
    @autoreleasepool {
        /* Inert until a verified CarPlay host is wired up. */
    }
}
