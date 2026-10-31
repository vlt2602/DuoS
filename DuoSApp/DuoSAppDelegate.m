#import <UIKit/UIKit.h>

// Voi UIScene tren iOS 15, UIWindow duoc quan ly boi PhoneSceneDelegate.
// Khong tao UIWindow trong AppDelegate nua de tranh xung dot vong doi Scene.
@interface DuoSAppDelegate : UIResponder <UIApplicationDelegate>
@end

@implementation DuoSAppDelegate
- (BOOL)application:(__unused UIApplication *)application
didFinishLaunchingWithOptions:(__unused NSDictionary *)options {
    return YES;
}
@end
