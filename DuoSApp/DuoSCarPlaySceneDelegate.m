#import <UIKit/UIKit.h>
#import <CarPlay/CarPlay.h>

// Day la CarPlay Scene chinh thuc, KHONG gia mao entitlement.
// Chi duoc he thong kich hoat neu app co CarPlay entitlement hop le.
// Man hinh xe duoc CarPlay quan ly qua CPInterfaceController.
// Khong mo app khac, khong sua SpringBoard va khong tao CPWindow tuy tien.
@interface DuoSCarPlaySceneDelegate : UIResponder <CPTemplateApplicationSceneDelegate>
@property (nonatomic, strong) CPInterfaceController *controller;
@end

@implementation DuoSCarPlaySceneDelegate

- (void)templateApplicationScene:(__unused CPTemplateApplicationScene *)scene
   didConnectInterfaceController:(CPInterfaceController *)interfaceController {
    self.controller = interfaceController;
    CPListItem *status = [[CPListItem alloc]
        initWithText:@"DuoS"
        detailText:@"CarPlay Scene da ket noi"];
    CPListItem *notice = [[CPListItem alloc]
        initWithText:@"An toan khi lai xe"
        detailText:@"Khong mo them ung dung hay chuyen tiep cam ung"];
    CPListSection *section = [[CPListSection alloc] initWithItems:@[status, notice]];
    CPListTemplate *list = [[CPListTemplate alloc]
        initWithTitle:@"DuoS" sections:@[section]];
    [interfaceController setRootTemplate:list
                               animated:NO
                             completion:^(__unused BOOL succeeded,
                                          __unused NSError *error) {
        // Khong gui trang thai len mang va khong ghi thong tin ca nhan.
    }];
}

- (void)templateApplicationScene:(__unused CPTemplateApplicationScene *)scene
didDisconnectInterfaceController:(__unused CPInterfaceController *)interfaceController {
    self.controller = nil;
}
@end
