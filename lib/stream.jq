########################################################################
# Stream functions
########################################################################

include "lib/control";

# Extract the first element of a stream
def cut(g):
    label $pipe | g | ., break $pipe
;

# `cycle` ties a finite stream into a circular one, or equivalently, the
# infinite repetition of the original stream.  It is the identity on infinite
# streams
def cycle(g):
    def R: g, R;
    R
;

# `drop` returns the suffix of stream `g` after the first `n` elements, or
# `empty` after all elements are dropped
def drop($n; g):
    if $n < 0 then g
    else foreach g as $item
            ($n;
            if . < 0 then . else .-1 end;
            when(. < 0; $item))
    end
; 

# Produce enumerated items from `g`
def enum(g):
   foreach g as $item
       (-1; .+1; [., $item])
;

# `replicate(n; x)` is a list of length `n` with `x` the value of every element
def replicate($n; $x):
#   [limit($n; repeat(x))]
    [range($n) | $x]
;

def replicate($n):
    . as $x |
    replicate($n; $x);

# `take(n; g)` returns the prefix of `g` of length `n`
def take($n; g):
    if $n < 0
    then g
    else label $loop |
        foreach g as $item
            ($n; if . < 1
                 then break $loop
                 else .-1 end;
             $item)
    end
; 

# Not optimized `zip`!
#?def zip(g; h):
#?    [[g], [h]] | transpose[]
#?;

# `zip` takes two streams and returns a stream of corresponding pairs.
# If one input list is short, excess elements of the shorter stream are
# replaced with `null`.
def zip(g; h):
    [[g], [h]] as $pair |
    ($pair | map(length) | max) as $longest |
    foreach range($longest) as $j
        (null; null; [$pair[0][$j], $pair[1][$j]])
;

# Generalized `zip` for 2 or more generators
def zipN:
    . as $in |
    (map(length) | max) as $longest |
    length as $N |
    foreach range($longest) as $j
        (null; reduce range($N) as $i
                    ([]; . + [$in[$i][$j]]))
;

# 3, 4...
def zip(a; b; c): [[a], [b], [c]] | zipN;
def zip(a; b; c; d): [[a], [b], [c], [d]] | zipN;

# vim:ai:sw=4:ts=4:et:syntax=python
