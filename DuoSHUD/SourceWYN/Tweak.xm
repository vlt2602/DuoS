#import <CoreLocation/CoreLocation.h>

// Bước 1: không truy cập GPS và không can thiệp WYN.
// Bước 4 sẽ thêm bộ thu dữ liệu có kiểm soát vòng đời.
%ctor {
    // Cố ý không thực hiện thao tác nào.
}
