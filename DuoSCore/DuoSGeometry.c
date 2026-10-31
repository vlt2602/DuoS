#include "DuoSGeometry.h"
#include <math.h>
#include <string.h>

bool DuoSComputeTwoPanes(DuoSRect canvas,
                         float leftFraction,
                         float gap,
                         DuoSPaneFrames *out) {
    if (out == NULL) return false;
    memset(out, 0, sizeof(*out));

    // Chan NaN/Infinity, toa do am khong hop le khong tu dong duoc sua.
    if (!isfinite(canvas.x) || !isfinite(canvas.y) ||
        !isfinite(canvas.width) || !isfinite(canvas.height) ||
        !isfinite(leftFraction) || !isfinite(gap)) {
        return false;
    }

    // Tranh frame am va giam nguy co UI qua hep de tuong tac.
    if (canvas.width <= 0.0f || canvas.height <= 0.0f ||
        leftFraction < 0.25f || leftFraction > 0.75f ||
        gap < 0.0f || gap > 32.0f) {
        return false;
    }

    const float usableWidth = canvas.width - gap;
    const float leftWidth = usableWidth * leftFraction;
    const float rightWidth = usableWidth - leftWidth;
    const float rightX = canvas.x + leftWidth + gap;
    if (!isfinite(rightX) || !isfinite(canvas.x + canvas.width) ||
        leftWidth < 120.0f || rightWidth < 120.0f) {
        return false;
    }

    // Hai khung khong chong len nhau; do rong cong gap = canvas.width.
    out->left = (DuoSRect){canvas.x, canvas.y, leftWidth, canvas.height};
    out->right = (DuoSRect){rightX, canvas.y, rightWidth, canvas.height};
    return true;
}
