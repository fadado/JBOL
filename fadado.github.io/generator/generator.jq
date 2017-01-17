module {
    name: "generator",
    description: "Common generators operations",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

########################################################################
# Predicates

def isempty(g): #:: (<α>) -> boolean
    (label $block | g | 1, break $block)//0
    | .==0  # count is 0
;

def nonempty(g): #:: (<α>) -> boolean
    (label $block | g | 1 , break $block)//0
    | .==1  # count is > 0
;

def count(g): #:: (<α>) -> number
    reduce g as $_ (0; .+1)
;

# Redefine some jq primitives
def all(g; p): #:: (<α>;α->boolean) -> boolean
    isempty(g | if p then empty else . end)
;
def all: #:: [boolean]| -> boolean
    all(.[]; .)
;
def all(p): #:: [α]|(α->boolean) -> boolean
    all(.[]; p)
;

def any(g; p): #:: (<α>;α->boolean) -> boolean
    nonempty(g | if p then . else empty end)
;
def any: #:: [boolean]| -> boolean
    any(.[]; .)
;
def any(p): #:: [α]|(α->boolean) -> boolean
    any(.[]; p)
;

########################################################################
# Generators as streams

# concat:      g++h         g,h
# id:          id x         x|.
# map:         map f g      g|f
# filter:      filter p g   g|select(p)
# apply:       f a          a|f
# compose:     f·g          g|f

# Extract the first element of a stream.
#
def first(g): #:: (<α>) ->α
    label $pipe
    | g
    | . , break $pipe
;

# Extract the last element of a stream.
#
def last(g): #:: (<α>) ->α
    reduce g as $item
        (null; $item)
;

# Extract the nth element of a stream.
#
def nth($n; g): #:: (number;<α>-> α
    select($n >= 0) | # not defined for n<0 and n>=#g
    label $loop
    | foreach g as $item ($n; .-1;
        if . == -1 then $item , break $loop else empty end)
;

# Produces enumerated items from `g`.
#
def enum(g): #:: (<α>) -> <[number,α]>
    foreach g as $item
        (-1; .+1; [.,$item])
;

# Ties a finite stream into a circular one, or equivalently, the
# infinite repetition of the original stream.  It is the identity on infinite
# streams. Equivalent to the `repeat` builtin.
#
def repeat(g): #:: (<α>) -> <α>, (α) -> <α>
    def r: g , r;
    r
;

# Returns the suffix of stream `g` after the first `n` elements, or
# `empty` after all elements are dropped
#
def drop($n; g): #:: (number;<α>) -> <α>
    select($n >= 0) | # not defined for n<0 and n>=#g
    if $n == 0
    then g
    else
        foreach g as $item ($n; .-1;
            if . < 0 then $item else empty end)
    end
;

#!def dropWhile(p; g):
#!# Warning: is in fact `filter`
#!    g | if p then empty else . end
#!;

# Remove the first element of a stream.
#
def rest(g): #:: (<α>) -> <α>
    foreach g as $item (1; .-1;
        if . < 0 then $item else empty end)
;

# Returns the prefix of `g` of length `n`.
#
def take($n; g): #:: (number;<α>) -> <α>
    select($n >= 0) | # not defined for n<0
    if $n == 0
    then g
    else
        label $loop
        | foreach g as $item ($n;
            if . < 1 then break $loop else .-1 end;
            $item)
    end
;

# Returns the prefix of `g` while `p` is true.
#
def takeWhile(p; g): #:: (α->boolean;<α>) -> <α>
    label $pipe
    | g
    | if p
      then .
      else break $pipe
      end
;

# Analogous to array[start; stop] applied to streams.
#
def slice($i; $j; g): #:: (number;number;<α>) -> <α>
    select($i < $j) |
    take($j-$i; drop($i; g))
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
def zip(g; h): #:: (<α>;<β>) -> <[α,β]>
    [[g], [h]] as $pair
    | ($pair | map(length) | max) as $longest
    | range($longest)
    | [$pair[0][.], $pair[1][.]]
;

# Generalized `zip` for 2 or more generators.
#
def zip: #:: [[α],[β]...] -> <[α,β...]>
    . as $in
    | (map(length) | max) as $longest
    | length as $N
    | foreach range($longest) as $j (null;
        reduce range($N) as $i
            ([]; . + [$in[$i][$j]]))
;
def zip(g1; g2; g3):
    [[g1], [g2], [g3]] | zip
;
def zip(g1; g2; g3; g4):
    [[g1], [g2], [g3], [g4]] | zip
;
def zip(g1; g2; g3; g4; g5):
    [[g1], [g2], [g3], [g4], [g5]] | zip
;
def zip(g1; g2; g3; g4; g5; g6):
    [[g1], [g2], [g3], [g4], [g5], [g6]] | zip
;
def zip(g1; g2; g3; g4; g5; g6; g7):
    [[g1], [g2], [g3], [g4], [g5], [g6], [g7]] | zip
;

# Dot product (very inefficient zip on infinite streams)
def parallel(g1; g2):
  first(g1) as $g1 | first(g2) as $g2
  | [$g1, $g2], parallel(rest(g1); rest(g2))
;

def parallel(g1; g2; g3):
  first(g1) as $g1 | first(g2) as $g2 | first(g3) as $g3
  | [$g1, $g2, $g3], parallel(rest(g1); rest(g2); rest(g3))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
