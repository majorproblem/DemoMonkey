#!/bin/sh
# End-to-end checks for the Services and the line-ending settings.
#
# Drives the real application, so it needs a GUI session and will quit and
# relaunch DemoMonkey several times.  It also writes and then deletes the
# defaultLineEnding preference.
#
#     Tests/run-service-checks.sh [path/to/DemoMonkey.app]
set -e
DIR=$(cd "$(dirname "$0")" && pwd)
OUT="$DIR/build"
BUNDLE_ID=se.chronologic.DemoMonkey

if [ -n "$1" ]; then
    APP="$1"
else
    APP=$(ls -d "$HOME"/Library/Developer/Xcode/DerivedData/DemoMonkey-*/Build/Products/Development/DemoMonkey.app 2>/dev/null | head -1)
fi
[ -d "$APP" ] || { echo "DemoMonkey.app not found; pass its path as an argument" >&2; exit 2; }
echo "app: $APP"

"$DIR/build.sh" > /dev/null
"$OUT/gendoc"    "$DIR/build/saved-cr.demoMonkey" 0 > /dev/null   # file says carriage return
"$OUT/genlegacy" "$DIR/build/legacy.demoMonkey"      > /dev/null   # file says nothing

failures=0
check () { # check <label> <expected> <actual>
    if [ "$2" = "$3" ]; then
        printf '  PASS  %s\n' "$1"
    else
        printf '  FAIL  %s\n        expected: %s\n        actual:   %s\n' "$1" "$2" "$3"
        failures=$((failures + 1))
    fi
}
relaunch () {
    osascript -e 'tell application "DemoMonkey" to quit' 2>/dev/null || true
    i=0; while pgrep -x DemoMonkey > /dev/null && [ $i -lt 5 ]; do sleep 1; i=$((i + 1)); done
    open "$APP"; sleep 3
}
returned () { "$OUT/svc" "DemoMonkey/Get Next Line" | sed 's/.*| //'; }

echo
echo "Preference seeds a new document, and Create New Step round-trips through it:"
for pair in "1:<LF>" "0:<CR>" "2:<CR><LF>"; do
    pref=${pair%%:*}; sep=${pair##*:}
    defaults write "$BUNDLE_ID" defaultLineEnding -int "$pref"
    relaunch
    "$OUT/svc" "DemoMonkey/Create New Step" "show system
show users" > /dev/null
    sleep 1
    check "defaultLineEnding=$pref" "show system${sep}show users" "$(returned)"
done

echo
echo "A saved document keeps its own setting; a legacy file takes the preference:"
defaults write "$BUNDLE_ID" defaultLineEnding -int 1   # preference = line feed
relaunch
open -a "$APP" "$DIR/build/saved-cr.demoMonkey"; sleep 3
check "saved file overrides preference" "show system<CR>show users<CR>show time" "$(returned)"
open -a "$APP" "$DIR/build/legacy.demoMonkey"; sleep 3
check "legacy file uses preference"     "legacy one<LF>legacy two"               "$(returned)"

defaults delete "$BUNDLE_ID" defaultLineEnding 2>/dev/null || true
echo
if [ "$failures" -eq 0 ]; then echo "all checks passed"; else echo "$failures check(s) failed"; fi
exit "$failures"
