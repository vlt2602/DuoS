#import <Preferences/PSListController.h>

@interface DuoSRootListController : PSListController
@end

@implementation DuoSRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

@end
