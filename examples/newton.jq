#!/usr/local/bin/jq -cnRrf

import "fadado.github.io/generator/stream" as stream;
import "fadado.github.io/math" as math;

def nrsqrt:
    def square_root($N; $eps; diff):
        #
        def next: (.+$N/.) / 2;
        #
        def search(xs):
            [stream::take(2; xs)] as $ab |
            if ($ab|diff) <= $eps
            then $ab[1]
            else search(stream::rest(xs))
            end
        ;
        #
        $N/2 as $init |
        search($init|recurse(next))
    ;
    . as $n |
    0.00001 as $e |
# within
    square_root($n; $e; math::abs(.[0]-.[1]))
# relative
    #square_root($n; $e; math::abs(.[0]/.[1]-1))
;

########################################################################

def builtin:
    2|sqrt   | "sqrt(2)   == \(.)"
;

def newton:
    2|nrsqrt | "newton(2) == \(.)"
;

# Main
builtin, newton

# vim:ai:sw=4:ts=4:et:syntax=jq
