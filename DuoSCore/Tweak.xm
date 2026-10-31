#import <Foundation/Foundation.h>
#import "DuoSCrashGuard.h"
#import "../Shared/DuoSCarPlayState.h"

/* No private FBScene hooks until verified on iOS 15.8.8.
 * Crash guard runs first. Unexpected repeated startup => disable DuoS. */
%ctor {
    @autoreleasepool {
        if (!DuoSGuardBegin()) return;
        /* Reset stale CarPlay state after SpringBoard restart (fail closed). */
        DuoSCarPlayPublishVerified(NO);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            DuoSGuardMarkHealthy();
        });
    }
}
