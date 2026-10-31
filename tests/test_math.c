#include "../Shared/DuoSHUDCodec.h"
#include "../Shared/DuoSTouchMapper.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>
static int near(double a, double b) { return fabs(a - b) < 0.00001; }
int main(void) {
    DuoSHUDSample a = { .speed_tenths = 803, .limit_kmh = 80,
                       .flags = 3, .sequence = 4095, .uptime_seconds = 4194300 };
    uint64_t word = 0;
    assert(DuoSHUDEncode(&a, &word));
    DuoSHUDSample b = {0};
    assert(DuoSHUDDecode(word, &b));
    assert(b.speed_tenths == 803 && b.limit_kmh == 80 && b.flags == 3 &&
           b.sequence == 4095 && b.uptime_seconds == 4194300);
    assert(DuoSHUDIsFresh(&b, 2, 10)); /* wraps after 2^22 */
    assert(!DuoSHUDIsFresh(&b, 100, 10));
    assert(!DuoSHUDEncode(NULL, &word));
    assert(!DuoSHUDDecode(0, &b));

    DuoSRect screen = { 100, 20, 2100, 900 }; /* 21:9 style viewport */
    DuoSRect app = { 0, 0, 390, 844 };
    DuoSPoint result = {0};
    assert(DuoSTouchMap((DuoSPoint){1150,470}, screen, app, DUOS_ROT_0, &result));
    assert(near(result.x, 195) && near(result.y, 422));
    assert(DuoSTouchMap((DuoSPoint){100,20}, screen, app, DUOS_ROT_90, &result));
    assert(near(result.x, 0) && near(result.y, 844));
    assert(DuoSTouchMap((DuoSPoint){100,20}, screen, app, DUOS_ROT_180, &result));
    assert(near(result.x, 390) && near(result.y, 844));
    assert(DuoSTouchMap((DuoSPoint){100,20}, screen, app, DUOS_ROT_270, &result));
    assert(near(result.x, 390) && near(result.y, 0));
    assert(!DuoSTouchMap((DuoSPoint){0,0}, screen, app, DUOS_ROT_0, &result));
    assert(!DuoSTouchMap((DuoSPoint){100,20}, (DuoSRect){0,0,0,1}, app, DUOS_ROT_0, &result));
    DuoSRect square = {0, 0, 720, 720};
    assert(DuoSTouchMap((DuoSPoint){360,360}, square, app, DUOS_ROT_0, &result));
    assert(near(result.x,195) && near(result.y,422));
    puts("DuoS HUD codec + touch mapping: PASS");
    return 0;
}
