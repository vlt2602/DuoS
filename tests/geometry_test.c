#include "DuoSGeometry.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>

static int near(float a, float b) {
    return fabsf(a - b) <= 0.001f;
}

int main(void) {
    DuoSPaneFrames panes;
    const DuoSRect canvas = {12.0f, 8.0f, 800.0f, 480.0f};

    assert(DuoSComputeTwoPanes(canvas, 0.50f, 8.0f, &panes));
    assert(near(panes.left.x, 12.0f));
    assert(near(panes.left.width, 396.0f));
    assert(near(panes.right.x, 416.0f));
    assert(near(panes.right.width, 396.0f));
    assert(near(panes.left.height, 480.0f));

    assert(DuoSComputeTwoPanes(canvas, 0.65f, 8.0f, &panes));
    assert(near(panes.left.width, 514.8f));
    assert(near(panes.right.width, 277.2f));
    assert(near(panes.right.x + panes.right.width, 812.0f));

    // Khong du diem hien thi hoac gia tri khong hop le -> khong ve frame.
    assert(!DuoSComputeTwoPanes((DuoSRect){0, 0, 200, 400}, 0.5f, 8, &panes));
    assert(near(panes.left.width, 0.0f) && near(panes.right.width, 0.0f));
    assert(!DuoSComputeTwoPanes(canvas, NAN, 8, &panes));
    assert(!DuoSComputeTwoPanes(canvas, 0.5f, -1, &panes));
    assert(!DuoSComputeTwoPanes(canvas, 0.5f, 33, &panes));
    assert(!DuoSComputeTwoPanes(canvas, 0.10f, 8, &panes));
    assert(!DuoSComputeTwoPanes(canvas, 0.5f, 8, NULL));

    puts("DuoS geometry tests passed.");
    return 0;
}
