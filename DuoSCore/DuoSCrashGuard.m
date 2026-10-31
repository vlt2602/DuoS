#import "DuoSCrashGuard.h"
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static const char *kBoot = "/var/mobile/Library/Preferences/.duos-booting";
static const char *kDisabled = "/var/mobile/Library/Preferences/.duos-disabled";
static const char *kLog = "/var/mobile/Library/Preferences/com.duos.failsafe.log";

static long long up(void) {
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) return -1;
    return (long long)ts.tv_sec;
}
static void log_line(const char *message) {
    int fd = open(kLog, O_WRONLY | O_CREAT | O_APPEND | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (fd == -1) return;
    char buffer[240];
    int n = snprintf(buffer, sizeof(buffer), "uptime=%lld pid=%ld %s\n",
                     up(), (long)getpid(), message);
    if (n > 0 && n < (int)sizeof(buffer)) (void)write(fd, buffer, (size_t)n);
    close(fd);
}
BOOL DuoSGuardDisabled(void) {
    return access(kDisabled, F_OK) == 0;
}
BOOL DuoSGuardBegin(void) {
    if (DuoSGuardDisabled()) return NO;
    long long now = up();
    if (now < 0) return NO;
    int fd = open(kBoot, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
    if (fd >= 0) {
        char buf[48] = {0};
        ssize_t count = read(fd, buf, sizeof(buf) - 1);
        close(fd);
        if (count > 0) {
            char *end = NULL;
            long long old = strtoll(buf, &end, 10);
            if (end != buf && old >= 0 && now >= old && now - old <= 90) {
                int out = open(kDisabled, O_WRONLY | O_CREAT | O_EXCL |
                              O_CLOEXEC | O_NOFOLLOW, 0600);
                if (out >= 0) close(out);
                log_line("Unfinished recent launch: DuoS disabled");
                return NO;
            }
        }
    }
    fd = open(kBoot, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (fd < 0) {
        log_line("Boot marker unavailable: DuoS not started");
        return NO;
    }
    char buf[48];
    int n = snprintf(buf, sizeof(buf), "%lld\n", now);
    BOOL ok = n > 0 && n < (int)sizeof(buf) &&
              write(fd, buf, (size_t)n) == n && fsync(fd) == 0;
    close(fd);
    if (!ok) {
        log_line("Boot marker write error: DuoS not started");
        return NO;
    }
    log_line("Boot protection active");
    return YES;
}
void DuoSGuardMarkHealthy(void) {
    if (unlink(kBoot) == 0) log_line("Boot healthy");
}
