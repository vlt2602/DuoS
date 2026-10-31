#import <UIKit/UIKit.h>
@interface DuoSRootViewController : UIViewController
@end

@interface DuoSAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation DuoSAppDelegate
- (BOOL)application:(__unused UIApplication *)application
 didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions {
    // Ho tro iOS 15 o che do app delegate thong thuong, khong can CarPlay scene.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = UIColor.blackColor;
    self.window.rootViewController = [[DuoSRootViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
