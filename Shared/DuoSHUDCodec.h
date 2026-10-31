#ifndef DUOS_HUD_CODEC_H
#define DUOS_HUD_CODEC_H
#include <stdbool.h>
#include <stdint.h>

/* One atomic 64-bit Darwin notify state; no continuous flash writes.
 * Speed: tenths of km/h (4095 = unknown).
 * Limit: km/h (1023 = unknown).
 * uptime_seconds is modulo 2^22 seconds. */
typedef struct {
    uint16_t speed_tenths;
    uint16_t limit_kmh;
    uint8_t flags; /* 7 bits, zero means no alerts */
    uint16_t sequence;
    uint32_t uptime_seconds;
} DuoSHUDSample;

bool DuoSHUDEncode(const DuoSHUDSample *sample, uint64_t *word);
bool DuoSHUDDecode(uint64_t word, DuoSHUDSample *sample);
bool DuoSHUDIsFresh(const DuoSHUDSample *sample, uint32_t uptime, uint32_t max_age);
#endif
