#ifndef DUOS_SPEED_MATH_H
#define DUOS_SPEED_MATH_H
#include <stdbool.h>

// Dau vao mac dinh cua CoreLocation.speed: met/giay.
// Chi tra gia tri km/h khi mau GPS co gia tri hop le va con moi.
// ageSeconds duoc tinh tu thoi diem nhan mau, khong can timer.
// Mac dinh tra -1 (du lieu khong hop le).
bool DuoSSpeedKmhFromMetersPerSecond(double speedMps,
                                    double ageSeconds,
                                    int *outKmh);
#endif
