#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
/** Four explicit allowlisted applications. Presence must be established
 * through LaunchServices at runtime; no hardcoded "installed" defaults. */
@interface DSAppCatalog : NSObject
+ (NSArray<NSDictionary<NSString *, NSString *> *> *)installedCandidates;
@end
NS_ASSUME_NONNULL_END
