#ifndef DUOS_TOUCH_MAPPER_H
#define DUOS_TOUCH_MAPPER_H
#include <stdbool.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef struct { double x, y; } DuoSPoint;
typedef struct { double x, y, width, height; } DuoSRect;
typedef enum { DUOS_ROT_0 = 0, DUOS_ROT_90, DUOS_ROT_180, DUOS_ROT_270 } DuoSRotation;

/* viewport is the ACTUAL app display region in CarPlay coordinates, after
 * accounting for bars/insets/letterboxing, not the whole vehicle screen.
 * app_rect is the target app's logical coordinate space.
 * Outside viewport => false, no synthetic touch forwarded.
 * Pure math; this does not hook SpringBoard or generate touches. */
bool DuoSTouchMap(DuoSPoint touch, DuoSRect viewport, DuoSRect app_rect,
                  DuoSRotation rotation, DuoSPoint *mapped);
#ifdef __cplusplus
}
#endif
#endif
