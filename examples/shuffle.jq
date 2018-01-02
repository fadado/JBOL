#!/usr/local/bin/jq -cnRrf

import "fadado.github.io/array/choice" as choice;

# test
def main($N):
    range(10) as $i
    | [range($N)]
    | choice::shuffle
    | ($i, sort == [range($N)], .)
;

main(12)

# vim:ai:sw=4:ts=4:et:syntax=jq
