#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";

# Smart N-Queens

def queens($n):
    def safe($i; $j):
        every(
            range($i) as $k
            | .[$k] as $l
            | (($i-$k)|length) != (($j-$l)|length)
        )
    ;
    def qput($row; $avail):
        if $row == $n # $avail == []
        then .
        else
            $avail[] as $col # choose a column
            | if safe($row; $col)
              then .[$row]=$col | qput($row+1; $avail-[$col])
              else empty end
        end
    ;
    #
    [] as $board |
    0  as $first_row |
    [range($n)] as $available_columns |
    #
    $board|qput($first_row; $available_columns)
;

queens(8)

# vim:ai:sw=4:ts=4:et:syntax=jq
