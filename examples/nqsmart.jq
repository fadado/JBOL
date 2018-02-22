#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";

# Smart N-Queens

def queens($n; $columns):
    def safe($i; $j):
        every(
            range($i) as $k
            | .[$k] as $l
            | (($i-$k)|fabs) != (($j-$l)|fabs)
        )
    ;
    def available_columns:
        . as $board
        | $columns - $board
    ;
    def qput:
        length as $row
        | if $row == $n # assert(available_columns == [])
          then . # one solution found
          else
            available_columns[] as $column
            | select(safe($row; $column))
            | .[$row]=$column
            | qput
          end
    ;
    #
    [] | qput
;

8 as $N | queens($N; [range($N)])

# vim:ai:sw=4:ts=4:et:syntax=jq
