module {
    name: "stream",
    description: "Operations on generators considered as streams",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

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
def member($a; stream): #:: a|(a;*a) => boolean
#   any(stream; . == $a)
    false==isempty(stream | . == $a or empty)
;
def member(stream): #:: a|(*a) => boolean
    member(.; stream)
;

# some common?
def common(stream; t):  #:: a|(*a;*a) => *a
    stream | select(member(t))
;

def sharing(stream; t):  #:: a|(*a;*a) => boolean
#   any(stream | member(t); .)
    false==isempty(stream | member(t) or empty)
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
    | label $loop
    | foreach stream as $item
        ($n; .-1; select(. == -1) | $item , break $loop)
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

# vim:ai:sw=4:ts=4:et:syntax=jq
