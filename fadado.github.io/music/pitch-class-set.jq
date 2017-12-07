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
    map(pc::transpose($interval))
;

# Counts the number of transpositions for a pitch-class set.
def transpositions: #:: PCSET => number
    12 / math::gcd(12; length)
;

# Produces an inverted pitch-class set.
def invert: #:: PCSET => PCSET
    map(pc::invert)
;
def invert($interval): #:: PCSET|(PCI) => PCSET
    map(pc::invert($interval))
;

########################################################################
# Pure set operations (and array/set!)

# ~p
def complement: #:: PCSET => PCSET
    . as $pcset
    | [ range(12) | reject([.]|inside($pcset)) ]
;

########################################################################
# TODO: nomal, prime...

def normal: #:: PCSET => PCSET
    . as $set
    | length as $n
    | if $n == 0
    then []
    elif $n == 1
    then $set
    else
    # TODO:...
        # ensure order and uniquenes
        unique
        # build rotations
        | [., foreach range($n-1) as $_
                (.; array::rotate
                    | when(.[$n-1]-.[0] < 0; .[$n-1] += 12))
          ] as $r
        # get minimal distance
        | [$r[] | .[$n-1] - .[0]] | min as $m
        # remove rotations with distance > min
        | [$r[] | select((.[$n-1] - .[0]) == $m)] as $r
        #
        | $m,$r
        # choose normal order
        # normalize to 0..12
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
