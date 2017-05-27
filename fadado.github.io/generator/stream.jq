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
# Redefine some jq primitives

def all(stream; predicate): #:: a|(a->*b;b->boolean) => boolean
    failure(stream | predicate and empty)
;
def all: #:: [boolean]| => boolean
    all(.[]; .)
;
def all(predicate): #:: [a]|(a->boolean) => boolean
    all(.[]; predicate)
;

def any(stream; predicate): #:: a|(a->*b;b->boolean) => boolean
    success(stream | predicate or empty)
;
def any: #:: [boolean]| => boolean
    any(.[]; .)
;
def any(predicate): #:: [a]|(a->boolean) => boolean
    any(.[]; predicate)
;

########################################################################
# Generators as streams

# concat:      g ++ h         g , h
# id:          id x           x | .
# map:         map f g        g | f
# filter:      filter p g     g | select(p)
# apply:       f a            a | f
# compose:     f · g          g | f

# Count stream items.
#
def count(stream): #:: a|(a->*b) => number
    reduce stream as $ignore (0; .+1)
;

# Is a stream empty?.
#
# "failure" in goal terms
def isempty(stream): #:: a|(a->*b) => boolean
    asbool(stream)==false
;

# One result?
def singleton(stream): #:: a|(a->*b) => boolean
    [   label $exit |
        foreach stream as $item
            (2; if . >= 1 then .-1 else break $exit end; null)
    ] | length == 1
;

# Extract the first element of a stream.
#
# "once" in goal terms
def first(stream): #:: a|(a->*b) => ?b
    label $exit | stream | . , break $exit
;

# Extract the last element of a stream.
#
def last(stream): #:: a|(a->*b) => ?b
    reduce stream as $item
        (null; $item)
    | select(. != null)
;

# Extract the nth element of a stream.
#
def nth($n; stream): #:: a|(number;a->*b) => ?b
    select($n >= 0) | # not defined for n<0 and n>=#stream
    label $exit
    | foreach stream as $item
        ($n; .-1; select(. == -1) | $item , break $exit)
;

# Produces enumerated items from `stream`.
#
def enum(stream): #:: a|(a->*b) => *[number,b]
    foreach stream as $item
        (-1; .+1; [.,$item])
;

# Ties a finite stream into a circular one, or equivalently, the
# infinite repetition of the original stream.  It is the identity on infinite
# streams. Equivalent to the `repeat` builtin.
#
def repeat(stream): #:: a|(a->*b) => *b
    def r: stream , r;
    r
;

# Returns the suffix of `stream` after the first `n` elements, or
# `empty` after all elements are dropped
#
def drop($n; stream): #:: a|(number;a->*b) => *b
    select($n >= 0) | # not defined for n < 0 or n >= #stream
    if $n == 0
    then stream
    else
        foreach stream as $item
            ($n; .-1; select(. < 0) | $item)
    end
;

#!def dropWhile(predicate; stream):
#!# Warning: is in fact `filter`
#!    stream | select(predicate)
#!;

# Remove the first element of a stream.
#
def rest(stream): #:: a|(a->*b) => *b
    foreach stream as $item
        (1; .-1; select(. < 0) | $item)
;

# Returns the prefix of `stream` of length `n`.
#
def take($n; stream): #:: a|(number;a->*b) => *b
    select($n >= 0) | # not defined for n<0
    if $n == 0
    then stream
    else
        label $exit
        | foreach stream as $item
            ($n;
             if . >= 1 then .-1 else break $exit end;
             $item)
    end
;

# Returns the prefix of `stream` while `predicate` is true.
#
def takeWhile(predicate; stream): #:: a|(b->boolean;a->*b) => *b
#   try ( stream | unless(predicate; cancel) ) catch cancelled
    label $exit
    | stream
    | unless(predicate; break $exit)
;

# Analogous to array[start; stop] applied to streams.
#
def slice($i; $j; stream): #:: a|(number;number;a->*b) => *b
    select($i < $j)
    | take($j-$i; drop($i; stream))
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
def zip: #:: [[a],[b]...]| => *[a,b,...]
    . as $in
    | (map(length) | max) as $longest
    | length as $N
    | foreach range($longest) as $j (null;
        reduce range($N) as $i
            ([]; . + [$in[$i][$j]]))
;
def zip(g1; g2; g3): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3]] | zip
;
def zip(g1; g2; g3; g4): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3], [g4]] | zip
;
def zip(g1; g2; g3; g4; g5): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3], [g4], [g5]] | zip
;
def zip(g1; g2; g3; g4; g5; g6): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3], [g4], [g5], [g6]] | zip
;
def zip(g1; g2; g3; g4; g5; g6; g7): #:: x|(x->*a;x->*b;...) => *[a,b,...]
    [[g1], [g2], [g3], [g4], [g5], [g6], [g7]] | zip
;

# Dot product (very inefficient zip on infinite streams)
def parallel(g1; g2): #:: x|(x->*a,x->*b) => *[a,b]
  first(g1) as $g1 | first(g2) as $g2
  | [$g1, $g2], parallel(rest(g1); rest(g2))
;

def parallel(g1; g2; g3): #:: x|(x->*a,x->*b,...) => *[a,b,...]
  first(g1) as $g1 | first(g2) as $g2 | first(g3) as $g3
  | [$g1, $g2, $g3], parallel(rest(g1); rest(g2); rest(g3))
;

# vim:ai:sw=4:ts=4:et:syntax=jq