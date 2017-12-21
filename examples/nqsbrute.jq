#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";
import "fadado.github.io/math" as math;
import "fadado.github.io/generator/choice" as choice;

# Streams based N-Queens by brute force

def queens($n):
    def generate:
        [range(0; $n)]
        | choice::permutations
    ;
    def all_safe:
        every(
            range(0; length-1) as $i
            | .[$i] as $j
            | range($i+1; length) as $k
            | .[$k] as $l
            | math::abs($i-$k) != math::abs($j-$l)
        )
    ;
    def and_test:
        select(all_safe)
    ;
    generate | and_test
;

queens(8)

# vim:ai:sw=4:ts=4:et:syntax=jq
