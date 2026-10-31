#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${TMPDIR:-/tmp}/duos-math-test-$$"
trap 'rm -f "$OUT"' EXIT
cc -std=c11 -Wall -Wextra -Werror -pedantic -O2 \
    Shared/DuoSHUDCodec.c Shared/DuoSTouchMapper.c tests/test_math.c \
    -lm -o "$OUT"
"$OUT"
