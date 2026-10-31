#include "DuoSHUDCodec.h"
#define TIME_MASK UINT32_C(0x003fffff)
#define VALID_BIT UINT64_C(0x80)

bool DuoSHUDEncode(const DuoSHUDSample *s, uint64_t *out) {
    if (!s || !out || s->speed_tenths > 4095 || s->limit_kmh > 1023 ||
        s->flags > 127 || s->sequence > 4095) return false;
    *out = (uint64_t)s->speed_tenths |
           ((uint64_t)s->limit_kmh << 12) |
           (((uint64_t)s->flags | VALID_BIT) << 22) |
           ((uint64_t)s->sequence << 30) |
           ((uint64_t)(s->uptime_seconds & TIME_MASK) << 42);
    return true;
}
bool DuoSHUDDecode(uint64_t in, DuoSHUDSample *s) {
    if (!s || !(in & (VALID_BIT << 22))) return false;
    s->speed_tenths = (uint16_t)(in & UINT64_C(0xfff));
    s->limit_kmh = (uint16_t)((in >> 12) & UINT64_C(0x3ff));
    s->flags = (uint8_t)((in >> 22) & UINT64_C(0x7f));
    s->sequence = (uint16_t)((in >> 30) & UINT64_C(0xfff));
    s->uptime_seconds = (uint32_t)((in >> 42) & TIME_MASK);
    return true;
}
bool DuoSHUDIsFresh(const DuoSHUDSample *s, uint32_t now, uint32_t max_age) {
    if (!s || max_age >= (UINT32_C(1) << 21)) return false;
    return (((now & TIME_MASK) - (s->uptime_seconds & TIME_MASK)) & TIME_MASK) <= max_age;
}
