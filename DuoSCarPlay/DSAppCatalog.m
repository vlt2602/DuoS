#import "DSAppCatalog.h"
#import <objc/runtime.h>
#import <dlfcn.h>

/* Only inspect installed apps; do not install, launch, or change entitlements. */
@implementation DSAppCatalog
+ (NSArray<NSDictionary<NSString *, NSString *> *> *)installedCandidates {
    static NSArray<NSDictionary<NSString *, NSString *> *> *allowlist;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        allowlist = @[
            @{@"name":@"Waze", @"id":@"com.waze.iphone"},
            @{@"name":@"VietMap Live", @"id":@"vn.vietmap.live"},
            @{@"name":@"GOFA", @"id":@"com.lumi.GOFA"},
            @{@"name":@"WYN", @"id":@"com.wynauto.wyn"}
        ];
    });

    Class proxyClass = NSClassFromString(@"LSApplicationProxy");
    if (!proxyClass) {
        (void)dlopen("/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices",
                     RTLD_LAZY | RTLD_LOCAL);
        proxyClass = NSClassFromString(@"LSApplicationProxy");
    }
    SEL lookup = NSSelectorFromString(@"applicationProxyForIdentifier:");
    if (!proxyClass || ![proxyClass respondsToSelector:lookup]) return @[];
    IMP imp = [proxyClass methodForSelector:lookup];
    if (!imp) return @[];
    id (*resolve)(id, SEL, NSString *) = (id (*)(id, SEL, NSString *))imp;
    NSMutableArray *installed = [NSMutableArray arrayWithCapacity:4];
    SEL bundleURLSelector = NSSelectorFromString(@"bundleURL");
    SEL idSelector = NSSelectorFromString(@"applicationIdentifier");
    for (NSDictionary *candidate in allowlist) {
        NSString *identifier = candidate[@"id"];
        id proxy = resolve(proxyClass, lookup, identifier);
        if (!proxy || ![proxy respondsToSelector:bundleURLSelector] ||
            ![proxy respondsToSelector:idSelector]) continue;
        NSURL *(*getURL)(id, SEL) = (NSURL *(*)(id, SEL))[proxy methodForSelector:bundleURLSelector];
        NSString *(*getID)(id, SEL) = (NSString *(*)(id, SEL))[proxy methodForSelector:idSelector];
        NSURL *location = getURL ? getURL(proxy, bundleURLSelector) : nil;
        NSString *actualID = getID ? getID(proxy, idSelector) : nil;
        if ([location isKindOfClass:NSURL.class] && location.isFileURL &&
            [actualID isEqualToString:identifier]) [installed addObject:candidate];
    }
    return installed;
}
@end
