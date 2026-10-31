#include "DuoSSpeedMath.h"
#include <math.h>

bool DuoSSpeedKmhFromMetersPerSecond(double speedMps,
                                    double ageSeconds,
                                    int *outKmh) {
    if (outKmh == 0) return false;
    *outKmh = -1;

    // Toc do am trong CLLocation nghia la khong xac dinh.
    if (!isfinite(speedMps) || !isfinite(ageSeconds)) return false;
    if (speedMps < 0.0 || speedMps > 100.0) return false;
    if (ageSeconds < 0.0 || ageSeconds > 5.0) return false;

    double kmh = speedMps * 3.6;
    if (!isfinite(kmh)) return false;
    *outKmh = (int)lround(kmh);
    return true;
}
