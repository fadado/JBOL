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
#   + all in package array

# Produces the pitch-class set
def new: #:: <array^string>| => PCSET
#   . as $x
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
def format: #:: PCSET| => string
#   . as $pcset
    add(.[] | pc::format; "")
;

########################################################################

# Produces a transposed pitch-class set.
def transpose($interval): #:: PCSET|(PCI) => PCSET
#   . as $pcset
    map(pc::transpose($interval))
;

# Counts the number of transpositions for a pitch-class set.
def transpositions: #:: PCSET| => number
#   . as $pcset
    12 / math::gcd(12; length)
;

# Produces an inverted pitch-class set.
def invert: #:: PCSET| => PCSET
#   . as $pcset
    map(pc::invert)
;
def invert($interval): #:: PCSET|(PCI) => PCSET
#   . as $pcset
    map(pc::invert($interval))
;

########################################################################
# pure set operations (and array/set!)

# ~p
def complement: #:: PCSET| => PCSET
    . as $pcset
    | [ range(12) | reject([.]|inside($pcset)) ]
;

########################################################################
# TODO: nomal, prime...

# vim:ai:sw=4:ts=4:et:syntax=jq
