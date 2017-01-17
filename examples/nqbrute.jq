#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";
import "fadado.github.io/generator/choice" as choice;

# N-Queens by brute force
#
# Usage:
#   ./nqbrute.jq --argjson N n
#

def queens($n):
    def generate:
        [range(0; $n)]
        | choice::permutation
    ;
    def all_safe:
        def ascending:
            [range(0; length) as $row | .[$row] as $col | $row+$col]
        ;
        def descending:
            [range(0; length) as $row | .[$row] as $col | $row-$col]
        ;
        def repeated:
            sort
            | some(
                range(1; length) as $i
                | .[$i]==.[$i-1]
            )
        ;
        (ascending|repeated|not) and (descending|repeated|not)
    ;
    def and_test:
        select(all_safe)
    ;
    generate | and_test
;

queens(8)

# vim:ai:sw=4:ts=4:et:syntax=jq
