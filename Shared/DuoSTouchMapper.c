#include "DuoSTouchMapper.h"
#include <math.h>
static bool valid(DuoSRect r) {
    return isfinite(r.x) && isfinite(r.y) && isfinite(r.width) &&
           isfinite(r.height) && r.width > 0.0 && r.height > 0.0;
}
bool DuoSTouchMap(DuoSPoint p, DuoSRect viewport, DuoSRect app,
                  DuoSRotation rotation, DuoSPoint *out) {
    if (!out || !valid(viewport) || !valid(app) || !isfinite(p.x) ||
        !isfinite(p.y) || rotation < DUOS_ROT_0 || rotation > DUOS_ROT_270) return false;
    double u = (p.x - viewport.x) / viewport.width;
    double v = (p.y - viewport.y) / viewport.height;
    if (u < 0.0 || u > 1.0 || v < 0.0 || v > 1.0) return false;
    double x = u, y = v;
    switch (rotation) {
        case DUOS_ROT_0: break;
        case DUOS_ROT_90:  x = v; y = 1.0 - u; break;
        case DUOS_ROT_180: x = 1.0 - u; y = 1.0 - v; break;
        case DUOS_ROT_270: x = 1.0 - v; y = u; break;
        default: return false;
    }
    out->x = app.x + x * app.width;
    out->y = app.y + y * app.height;
    return true;
}
