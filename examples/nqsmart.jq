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
        unless($row == $n; # $avail == []
            $avail[] as $col # choose a column
            | keep(safe($row; $col);
                .[$row]=$col | qput($row+1; $avail-[$col]))
        )
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
