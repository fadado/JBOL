#!/usr/bin/jq -nRrf

# Usage:
#   ./star.jq --arg alphabet 'string' --argjson ordered true | less
#   ./star.jq --arg alphabet '01' --argjson ordered false | head -n 20
#

# Generate the infinite language of characters in `alphabet`

# Not "well ordered"
def star(s):
    "", ((s/"")[]) + star(s)
;

# "Well" ordered
def star_wo(s):
    "",
    star_wo(s) as $a | (s/"")[] as $b
    | $a + $b
;

# Entry point
def main:
    if $ordered
    then star_wo($alphabet)
    else star($alphabet)
    end
;

main

# vim:ai:sw=4:ts=4:et:syntax=python
