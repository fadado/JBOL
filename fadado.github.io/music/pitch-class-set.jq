module {
    name: "music/pitch-class-set",
    description: "Pitch-class sets functions",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";
import "fadado.github.io/math" as math;
import "fadado.github.io/word" as word;
import "fadado.github.io/music/pitch-class" as pc;

########################################################################
# Names used in type declarations
#
# PCLASS (pitch-class): 0..11
# PCI (pitch-class interval): 0..11
# PCSET (pitch-class set): [PCLASS]
#
# Useful primitives:
#   + length  :: PCSET => number
#   + reverse  :: PCSET => PCSET
#   + index  :: PCSET|(PCLASS) => number^null
#   + fromjson  :: string => PCSET
#   + tojson  :: PCSET => string
#   + set operations defined in package array

# Produces the pitch-class set
def new: #:: <array^string> => PCSET
    if isarray
    then
        unique | map(pc::new)
    elif isstring then
        if test("^[0-9te]+$")
        then # compact string
            (./"") | map(pc::new)
        else # JSON array
            fromjson
        end
    else typerror("array or string")
    end
;
def new($x): #:: (<array^string>) => PCSET
    $x | new
;

# Format a pitch-class set as a string
def format: #:: PCSET => string
    reduce (.[] | pc::format) as $s
        (""; .+$s)
;

# Howard Hanson format for pitch-class-sets
def name($flats): #:: PCSET|(boolean) => string
    . as $pcset
    | [range(length), 0] as $ndx
    | [range(length) as $i | $pcset[$ndx[$i]]|pc::interval($pcset[$ndx[$i+1]])] as $p # pattern
    | map(pc::name($flats)) as $n # name
    | ["₀","₁","₂","₃","₄","₅","₆","₇","₈","₉","₁₀","₁₁","₁₂"] as $d # digit
    | reduce range(length) as $i
        (""; . + $n[$i] + $d[$p[$i]])
#   | .[:-1]
;
def name: #:: PCSET => string
    name(false)
;

########################################################################

# Produces a transposed pitch-class set.
def transpose($i): #:: PCSET|(PCI) => PCSET
    map(pc::transpose($i))
;

# Counts the number of transpositions for a pitch-class set.
def transpositions: #:: PCSET => number
    12 / math::gcd(12; length)
;

# Produces an inverted pitch-class set.
def invert: #:: PCSET => PCSET
    map(pc::invert)
;
def invert($i): #:: PCSET|(PCI) => PCSET
    map(pc::invert($i))
;

########################################################################
# Pure set operations (plus all in array/set!)

# ~p
def complement: #:: PCSET => PCSET
    . as $pcset
    | [ range(12) | reject([.]|inside($pcset)) ]
;

########################################################################
# Set class

# normal form
def normal: #:: PCSET => PCSET
    if length < 2
    then .
    else
        # ensure order and uniquenes
        unique

        # store last index
        | (length-1) as $last

        # build rotations
        | [ . , foreach range($last) as $_
                    (.; word::rotate | .[$last] += 12) ]

        # get minimal distance in all rotations
        | (map(.[$last]-.[0]) | min) as $m

        # remove rotations with last distance > min
        | map(select(.[$last]-.[0] == $m))

        # choose normal order
        | label $fence
        | recurse(
            range(1; $last+1) as $i
            | (.[0][$i] - .[0][0]) as $x
            | (.[1][$i] - .[1][0]) as $y
            | if $x < $y
            then del(.[1])
            elif $x > $y
            then del(.[0])
            elif $i == $last # $x == $y
            then del(.[1])
            else empty # try next
            end)
        | select(length == 1)
        | . , break $fence

        # normalize to 0..12
        | [.[0][] | . % 12]
    end
;

# proto prime
def proto_: #:: PCSET => PCSET
    # assume . is in normal form
    when(.[0] != 0; transpose((12-.[0])))
;
def proto: #:: PCSET => PCSET
    normal | proto_
;

# forte prime
def prime_($i): #:: PCSET|(PCSET) => PCSET
    # assume . and $i are in proto form
    if . < $i then . else $i end
;
def prime_: #:: PCSET => PCSET
    prime_(invert|normal|proto_)
;

def prime: #:: PCSET => PCSET
    normal | proto_ | prime_
;

# vim:ai:sw=4:ts=4:et:syntax=jq
