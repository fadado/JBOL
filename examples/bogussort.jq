#!/usr/local/bin/jq -cnRrf

import "fadado.github.io/generator/choice" as choice;

def issorted:
    def _issorted($xs; $len):
        def r:
            if . >= $len
            then true
            elif $xs[.] < $xs[.-1]
            then false
            else .+1|r
            end
        ;
        1|r
    ;
    _issorted(.; length)
;

def bogussort:
    label $pipe
    | choice::shuffle
    | choice::permutation
    | if issorted
      then ., break $pipe
      else empty end
;

def main:
    [range(8)] | bogussort
;

main

# vim:ai:sw=4:ts=4:et:syntax=jq
