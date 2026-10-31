#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
/* Applies only to DuoS. If a prior startup was interrupted, fail closed.
 * Never changes another tweak's files or disables ElleKit globally. */
FOUNDATION_EXPORT BOOL DuoSGuardBegin(void);
FOUNDATION_EXPORT BOOL DuoSGuardDisabled(void);
FOUNDATION_EXPORT void DuoSGuardMarkHealthy(void);
NS_ASSUME_NONNULL_END
