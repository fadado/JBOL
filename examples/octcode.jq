#!/usr/local/bin/jq -cnRrf

import "fadado.github.io/generator/stream" as stream;

def chars: (./"")[];

def octcode:
    ("01"|chars) as $d2 |
    ("01234567"|chars) as $d1 |
    ("01234567"|chars) as $d0 |
    $d2+$d1+$d0
;

def deccode:
    label $out |
    ("01"|chars) as $d2 |
    ("0123456789"|chars) as $d1 |
    ("0123456789"|chars) as $d0 |
    if $d2 == "1" and $d1 == "2" and $d0 == "8"
    then break$out
    else $d2+$d1+$d0
    end
;

def hexcode:
    ("01234567"|chars) as $d1 |
    ("0123456789ABCDEF"|chars) as $d0 |
    $d1+$d0
;

# Fast:
[ [octcode], [deccode], [hexcode] ] | stream::zip

# Very slow:
#parallel(octcode; deccode; hexcode)

# vim:ai:sw=4:ts=4:et:syntax=jq
