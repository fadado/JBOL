#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";
import "fadado.github.io/array/tuple" as tuple;
import "fadado.github.io/array/choice" as choice;

def issorted:
    def _issorted($xs; $len):
        def r:
            . >= $len
            or $xs[.] >= $xs[.-1]
               and (.+1|r)
        ;
        1|r
    ;
    _issorted(.; length)
;

def bogussort:
    label $fence
    | choice::shuffle
    | tuple::permutations
    | select(issorted)
    | . , break $fence

#   | first(
#       tuple::permutations
#       | select(issorted)
#   )
;

def main:
    [range(8)] | bogussort
;

main

# vim:ai:sw=4:ts=4:et:syntax=jq
