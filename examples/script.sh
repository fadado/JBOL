#!/bin/sh

# Usage: script.sh "on" "one motion is optional"

STRING=${1?Expected string to find}
TARGET=${2?Expected target string}

# jq -MnRrf ...
exec jq \
    --monochrome-output  \
    --null-input \
    --raw-input \
    --raw-output \
    --from-file ${0%.sh}.jq \
    --arg string "$STRING" \
    --arg target "$TARGET"

# vim:ai:sw=4:ts=4:et:syntax=sh
