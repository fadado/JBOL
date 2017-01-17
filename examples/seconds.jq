#!/usr/local/bin/jq -nRrf

def chars: #:: string|-> <string>
    split("")[]
;

def main:
    label $pipe

    | ("012"|chars) as $h1
    | ("0123456789"|chars) as $h2

    | if $h1 == "2" and $h2 == "4"
    then break $pipe
    else . end

    | ("012345"|chars) as $m1
    | ("0123456789"|chars) as $m2

    | $h1+$h2+":"+$m1+$m2
;

main

# vim:ai:sw=4:ts=4:et:syntax=jq
