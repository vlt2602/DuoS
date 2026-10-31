#import <UIKit/UIKit.h>

@interface DuoSRootViewController : UIViewController
@end

// Cua so iPhone la cua so rieng. Khong lay cua so do gan sang CarPlay.
@interface DuoSPhoneSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation DuoSPhoneSceneDelegate
- (void)scene:(UIScene *)scene
willConnectToSession:(__unused UISceneSession *)session
     options:(__unused UISceneConnectionOptions *)options {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    window.rootViewController = [[DuoSRootViewController alloc] init];
    window.backgroundColor = [UIColor systemBackgroundColor];
    self.window = window;
    [window makeKeyAndVisible];
}
- (void)sceneDidDisconnect:(__unused UIScene *)scene {
    self.window = nil;
}
@end
