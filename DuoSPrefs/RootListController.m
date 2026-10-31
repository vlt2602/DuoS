#import <Preferences/PSListController.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "../Shared/DuoSCarPlayState.h"
#include <unistd.h>

@interface DuoSRootListController : PSListController
- (void)showDuoSStatus;
- (void)copyDuoSReport;
@end

@implementation DuoSRootListController
- (NSArray *)specifiers {
    if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    return _specifiers;
}
- (NSString *)report {
    BOOL car = DuoSCarPlayIsVerifiedConnected();
    BOOL disabled = access("/var/mobile/Library/Preferences/.duos-disabled",F_OK)==0;
    BOOL boot = access("/var/mobile/Library/Preferences/.duos-booting",F_OK)==0;
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    (void)version;
    return [NSString stringWithFormat:
      @"DuoS 0.3.0\niPhone: %@\niOS: %@\nCarPlayApp: %@\nChế độ an toàn: %@\nKhởi tạo: %@\nLưu ý: Chỉ báo phát hiện hoạt động CarPlayApp, không xác minh phần cứng xe.",
      UIDevice.currentDevice.model, UIDevice.currentDevice.systemVersion,
      car ? @"Đang hoạt động (chưa kiểm chứng trên xe)" : @"Chưa phát hiện",
      disabled ? @"Đã tự khóa DuoS sau lỗi" : @"Bình thường",
      boot ? @"Đang khởi tạo" : @"Không trong giai đoạn khởi tạo"];
}
- (void)showDuoSStatus {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Kiểm tra DuoS"
         message:[self report] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Sao chép" style:UIAlertActionStyleDefault
      handler:^(__unused UIAlertAction *action) {
        UIPasteboard.generalPasteboard.string = [self report];
      }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)copyDuoSReport { UIPasteboard.generalPasteboard.string = [self report]; }
@end
