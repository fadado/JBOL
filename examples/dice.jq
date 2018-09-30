#!/usr/local/bin/jq -cnRrf

import "fadado.github.io/math" as math;
import "fadado.github.io/math/chance" as chance;

def dice:
    1+chance::random(6; chance::randomize)
;

# test
def main($N):
    def average(g):
        math::sum(g) / math::count(g)
    ;
    range(4) |
    average(limit($N; dice))
    ,
    [ limit($N; dice) ]
;

main(149)

# vim:ai:sw=4:ts=4:et:syntax=jq
