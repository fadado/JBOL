#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";
import "fadado.github.io/array" as array;

# Smart N-Queens

def queens($n; $columns):
    def safe($j):
        length as $i | every(
            range($i) as $k
            | .[$k] as $l
            | (($i-$k)|fabs) != (($j-$l)|fabs)
        )
    ;
    def qput:
        if length == $n # assert(($columns - .) == [])
        then . # one solution found
        else
            # for each available column
            ($columns - .)[] as $column
            | select(safe($column))
            | array::push($column)
            | qput
        end
    ;
    #
    [] | qput
;

8 as $N | queens($N; [range($N)])

# vim:ai:sw=4:ts=4:et:syntax=jq
