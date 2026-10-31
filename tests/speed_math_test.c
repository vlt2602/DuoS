#include "DuoSSpeedMath.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>

int main(void) {
    int out = -1;
    assert(DuoSSpeedKmhFromMetersPerSecond(0.0, 0.0, &out) && out == 0);
    assert(DuoSSpeedKmhFromMetersPerSecond(27.7777778, 0.2, &out) && out == 100);
    assert(DuoSSpeedKmhFromMetersPerSecond(13.8888888, 5.0, &out) && out == 50);
    assert(!DuoSSpeedKmhFromMetersPerSecond(-1.0, 0.0, &out) && out == -1);
    assert(!DuoSSpeedKmhFromMetersPerSecond(11.0, 5.01, &out) && out == -1);
    assert(!DuoSSpeedKmhFromMetersPerSecond(11.0, -0.1, &out));
    assert(!DuoSSpeedKmhFromMetersPerSecond(101.0, 0.0, &out));
    assert(!DuoSSpeedKmhFromMetersPerSecond(INFINITY, 0.0, &out));
    assert(!DuoSSpeedKmhFromMetersPerSecond(NAN, 0.0, &out));
    assert(!DuoSSpeedKmhFromMetersPerSecond(10.0, NAN, &out));
    assert(!DuoSSpeedKmhFromMetersPerSecond(10.0, 0.0, NULL));
    puts("DuoS speed math tests passed.");
    return 0;
}
