#import <Foundation/Foundation.h>

// Bước 1: Tweak trống, không hook SpringBoard.
// Bước 2 sẽ thêm quản lý Scene và vòng đời ở đây.
%ctor {
    // Cố ý không thực hiện thao tác nào.
}
