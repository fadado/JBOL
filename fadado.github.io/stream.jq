module {
    name: "stream",
    description: "Common operations on generators considered as streams",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

########################################################################
# Generators as streams

# id:          id x           x | .
# concat:      g ++ h         g , h
# map:         map f g        g | f
# compose:     f · g          g | f
# apply:       f a            a | f
# filter:      filter p g     g | select(p)

# Count stream items.
#
def count(stream): #:: a|(a->*b) => number!
    reduce stream as $_ (0; .+1)
;

# . inside?
def member(stream): #:: a|(*a) => boolean
    . as $a
    | any(stream; . == $a)
;
def member($a; stream): #:: a|(a;*a) => boolean
    any(stream; . == $a)
;

# some common?
def common(stream; t):  #:: a|(*a;*a) => *a
    stream | select(member(t))
;

def sharing(stream; t):  #:: a|(*a;*a) => boolean
#   nonempty(common(stream; t))
    some(stream | member(t))
;

# Unique for streams
def distinct(stream):
    foreach stream as $x (
        {};
        ($x|type[0:1]+tostring) as $k
            | if has($k)
              then .["~"]=false
              else .[$k]=$x | .["~"]=true end;
        select(.["~"]) | $x)
;

# Remove the first element of a stream.
#
def rest(stream): #:: a|(a->*b) => *b
    foreach stream as $item
        (1; .-1; select(. < 0) | $item)
;

# One result?
def singleton(stream): #:: a|(a->*b) => boolean
    isempty(rest(stream))
;

# Extract the nth element of a stream.
#
def nth($n; stream): #:: a|(number;a->*b) => ?b
    select($n >= 0) # not defined for n<0 and n>=#stream
    | label $fence
    | foreach stream as $item
        ($n; .-1; select(. == -1) | $item , break $fence)
;

# Produces enumerated items from `stream`.
#
def enum(stream): #:: a|(a->*b) => *[number,b]
    foreach stream as $item
        (-1; .+1; [.,$item])
;

# Returns the suffix of `stream` after the first `n` elements, or
# `empty` after all elements are dropped
#
def drop($n; stream): #:: a|(number;a->*b) => *b
    select($n >= 0) # not defined for n < 0 or n >= #stream
    | if $n == 0
    then stream
    else
        foreach stream as $item
            ($n; .-1; select(. < 0) | $item)
    end
;

# Analogous to array[start; stop] applied to streams.
#
def slice($i; $j; stream): #:: a|(number;number;a->*b) => *b
    select($i < $j)
    | limit($j-$i; drop($i; stream))
;

#
# Not optimized `zip` => def zip(g; h): [[g], [h]] | transpose[]
#

# Takes two streams and returns a stream of corresponding pairs.
# If one input list is short, excess elements of the shorter stream are
# replaced with `null`.
#
# Warning: input streams cannot be infinite!
#
def zip(g; h): #:: x|(x->*a;x->*b) => *[a,b]
    [[g], [h]] as $pair
    | ($pair | map(length) | max) as $longest
    | range($longest)
    | [$pair[0][.], $pair[1][.]]
;

# Generalized `zip` for 2 or more streams.
#
def _zip: #:: [[a],[b]...]| => *[a,b,...]
    . as $in
    | (map(length) | max) as $longest
    | length as $n
    | foreach range($longest) as $j (null;
        reduce range($n) as $i
            ([]; . + [$in[$i][$j]]))
;
def zip(g1; g2; g3): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3]]
    | _zip
;
def zip(g1; g2; g3; g4): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3], [g4]]
    | _zip
;
def zip(g1; g2; g3; g4; g5): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3], [g4], [g5]]
    | _zip
;
def zip(g1; g2; g3; g4; g5; g6): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3], [g4], [g5], [g6]]
    | _zip
;
def zip(g1; g2; g3; g4; g5; g6; g7): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3], [g4], [g5], [g6], [g7]]
    | _zip
;

# vim:ai:sw=4:ts=4:et:syntax=jq
