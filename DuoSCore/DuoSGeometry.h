#ifndef DUOS_GEOMETRY_H
#define DUOS_GEOMETRY_H

#include <stdbool.h>

// Toa do theo diem (point), chua phu thuoc UIKit hay CarPlay.
typedef struct {
    float x;
    float y;
    float width;
    float height;
} DuoSRect;

typedef struct {
    DuoSRect left;
    DuoSRect right;
} DuoSPaneFrames;

// Chi tinh toan hai khung hinh, KHONG can thiep Scene hay su kien cham.
// leftFraction: 0.50 (50/50) hoac 0.65 (65/35).
// gap: khoang cach giua hai vung, 0..32 points.
// Tra ve false neu input loi hoac mot trong hai vung nho hon 120 points.
// Khi loi, *out duoc dat ve 0.
bool DuoSComputeTwoPanes(DuoSRect canvas,
                         float leftFraction,
                         float gap,
                         DuoSPaneFrames *out);

#endif  // DUOS_GEOMETRY_H
