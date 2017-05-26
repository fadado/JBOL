#!/usr/local/bin/jq -cnRrf

import "fadado.github.io/generator/stream" as stream;
import "fadado.github.io/generator/chance" as chance;

def dice:
    1+chance::random(6; chance::randomize)
;

# test
def main($N):
    range(4) |
    ([ stream::take($N; dice) ] | add / length),
    [ stream::take($N; dice) ]
;

main(149)

# vim:ai:sw=4:ts=4:et:syntax=jq
