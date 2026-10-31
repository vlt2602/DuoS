#import "DuoSHUDTransport.h"
#import <notify.h>

static const char *const kChannel = "com.duos.hud.v1.sample";
static int writer_token(void) {
    static int token = -1;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        int t = -1;
        if (notify_register_check(kChannel, &t) == NOTIFY_STATUS_OK) token = t;
    });
    return token;
}
BOOL DuoSHUDPublish(const DuoSHUDSample *sample) {
    uint64_t value = 0;
    if (!DuoSHUDEncode(sample, &value)) return NO;
    int token = writer_token();
    if (token < 0 || notify_set_state(token, value) != NOTIFY_STATUS_OK) return NO;
    return notify_post(kChannel) == NOTIFY_STATUS_OK;
}
int DuoSHUDSubscribe(dispatch_queue_t queue, void (^handler)(DuoSHUDSample)) {
    if (!queue || !handler) return -1;
    int token = -1;
    uint32_t status = notify_register_dispatch(kChannel, &token, queue, ^(int t) {
        uint64_t word = 0;
        DuoSHUDSample sample;
        if (notify_get_state(t, &word) == NOTIFY_STATUS_OK &&
            DuoSHUDDecode(word, &sample)) handler(sample);
    });
    return status == NOTIFY_STATUS_OK ? token : -1;
}
void DuoSHUDUnsubscribe(int token) {
    if (token >= 0) notify_cancel(token);
}
