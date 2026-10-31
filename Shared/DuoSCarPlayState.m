#import "DuoSCarPlayState.h"
#import <notify.h>
#include <stdint.h>

static const char *const kChannel = "com.duos.carplay.v1.verified";
static int shared_token(void) {
    static int token = -1;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        int t = -1;
        if (notify_register_check(kChannel, &t) == NOTIFY_STATUS_OK) token = t;
    });
    return token;
}
static uint64_t now_seconds(void) {
    return (uint64_t)[NSProcessInfo processInfo].systemUptime;
}
BOOL DuoSCarPlayPublishVerified(BOOL connected) {
    int token = shared_token();
    if (token < 0) return NO;
    uint64_t now = now_seconds();
    uint64_t value = (now << 1) | (connected ? 1ULL : 0ULL);
    if (notify_set_state(token, value) != NOTIFY_STATUS_OK) return NO;
    return notify_post(kChannel) == NOTIFY_STATUS_OK;
}
BOOL DuoSCarPlayIsVerifiedConnected(void) {
    int token = shared_token();
    uint64_t raw = 0;
    if (token < 0 || notify_get_state(token, &raw) != NOTIFY_STATUS_OK ||
        (raw & 1ULL) == 0) return NO;
    uint64_t then = raw >> 1, now = now_seconds();
    /* Requires a verified publisher heartbeat at least once / 60 seconds.
     * No publisher or crashed publisher => stale => all features stop. */
    return now >= then && now - then <= 60;
}
