#import <Foundation/Foundation.h>

// Bước 1: không sửa UIKit, ứng dụng, CarPlay hoặc bàn phím.
// Bước 3 sẽ bổ sung cơ chế tương thích giao diện có kiểm soát.
%ctor {
    // Cố ý không thực hiện thao tác nào.
}
