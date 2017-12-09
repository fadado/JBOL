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
import "fadado.github.io/math" as math;
import "fadado.github.io/array" as array;
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
    if type == "array"
    then
        unique | map(pc::new)
    elif type == "string" then
        if test("^[0-9te]+$")
        then # compact string
            (./"") | map(pc::new)
        else # JSON array
            fromjson
        end
    else type | "Type error: expected array or string, not \(.)" | error
    end
;
def new($x): #::(<array^string>) => PCSET
    $x | new
;

# Format a pitch-class set as a string
def format: #:: PCSET => string
    add(.[] | pc::format; "")
;

########################################################################

# Produces a transposed pitch-class set.
def transpose($interval): #:: PCSET|(PCI) => PCSET
    map(pc::transpose($interval)) | sort
;

# Counts the number of transpositions for a pitch-class set.
def transpositions: #:: PCSET => number
    12 / math::gcd(12; length)
;

# Produces an inverted pitch-class set.
def invert: #:: PCSET => PCSET
    map(pc::invert) | sort
;
def invert($interval): #:: PCSET|(PCI) => PCSET
    map(pc::invert($interval)) | sort
;

########################################################################
# Pure set operations (and array/set!)

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
                    (.; array::rotate | .[$last] += 12) ]

        # get minimal distance in all rotations
        | (map(.[$last]-.[0]) | min) as $m

        # remove rotations with last distance > min
        | map(select(.[$last]-.[0] == $m))

        # choose normal order
        | until(length == 1; 
            label $found
            | range(1;$last+1) as $i
            | (.[0][$i] - .[0][0]) as $x
            | (.[1][$i] - .[1][0]) as $y
            | if $x < $y
              then del(.[1]), break $found
              elif $y < $x
              then del(.[0]), break $found
              else # $x == $y
                if $i != $last
                then empty  # try next, else firts wins
                else del(.[1]), break $found
                end
              end)

        # normalize to 0..12
        | [.[0][] | . % 12]
    end
;

# proto prime
def proto_: #:: PCSET => PCSET
#   . as $normal
    when(.[0] != 0; transpose((12-.[0])))
;
def proto: #:: PCSET => PCSET
    normal | proto_
;

# forte prime
def prime_: #:: PCSET => PCSET
    . as $p # proto
    | (invert|normal|proto_) as $i
    | if $p < $i then $p else $i end
;
def prime_($i): #:: PCSET|(PCSET) => PCSET
    . as $p # proto, $i is also assumed in proto mode
    | if $p < $i then $p else $i end
;

def prime: #:: PCSET => PCSET
    normal | proto_ | prime_
;

# vim:ai:sw=4:ts=4:et:syntax=jq
