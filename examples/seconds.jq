#!/usr/local/bin/jq -nRrf

include "fadado.github.io/prelude";

def chars:
    split("")[]
;

def main:
    label $pipe

    | ("012"|chars) as $h1
    | ("0123456789"|chars) as $h2

    | when($h1 == "2" and $h2 == "4";
        break$pipe)

    | ("012345"|chars) as $m1
    | ("0123456789"|chars) as $m2

    | $h1+$h2+":"+$m1+$m2
;

main

# vim:ai:sw=4:ts=4:et:syntax=jq
