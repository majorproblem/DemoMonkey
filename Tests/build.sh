#!/bin/sh
# Build the manual Service test harnesses into Tests/build/.
# The generators link Step.m directly; Step.h relies on the project's prefix
# header rather than importing Cocoa itself, and the project is not ARC.
set -e
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
OUT="$DIR/build"
mkdir -p "$OUT"

clang -fobjc-arc -framework Cocoa "$DIR/svc.m" -o "$OUT/svc"

for tool in gendoc genlegacy; do
    # Step.m uses the pre-10.14 archiver API throughout; that is the project's
    # choice, not something these harnesses need to warn about.
    clang -fno-objc-arc -framework Cocoa -Wno-deprecated-declarations \
        -I"$ROOT" -include "$ROOT/DemoMonkey_Prefix.pch" \
        "$ROOT/Step.m" "$DIR/$tool.m" -o "$OUT/$tool"
done

echo "built: $OUT/svc $OUT/gendoc $OUT/genlegacy"
