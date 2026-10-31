#import <Foundation/Foundation.h>
#import "DuoSHUDCodec.h"
NS_ASSUME_NONNULL_BEGIN
/* Local Darwin notification bus, last-sample-wins; no plist writes or network. */
FOUNDATION_EXPORT BOOL DuoSHUDPublish(const DuoSHUDSample *sample);
FOUNDATION_EXPORT int DuoSHUDSubscribe(dispatch_queue_t queue,
    void (^handler)(DuoSHUDSample sample));
FOUNDATION_EXPORT void DuoSHUDUnsubscribe(int token);
NS_ASSUME_NONNULL_END
