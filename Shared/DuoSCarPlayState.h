#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
/* Must only be called from a REAL CarPlay lifecycle callback (not an
 * external-screen guess, Bluetooth event or accessory discovery).
 * Sender refreshes this while connected. Unknown / stale => disconnected. */
FOUNDATION_EXPORT BOOL DuoSCarPlayPublishVerified(BOOL connected);
FOUNDATION_EXPORT BOOL DuoSCarPlayIsVerifiedConnected(void);
NS_ASSUME_NONNULL_END
