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
import "fadado.github.io/string" as str;
import "fadado.github.io/music/pitch-class" as pc;

########################################################################
# pitch-class set operations

# pcs ∋ pc
def holds($pclass): #:: [number]|(number) => number
#   . as $pcset
    contains([$pclass])
;

def complement: #:: [number]| => [number]
    . as $pcset
    | [ range(12) | reject(pc::member($pcset)) ]
;

def union($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    . + $pcs | unique
;

def intersection($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    [ .[] | select(pc::member($pcs)) ]
;

def difference($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    [ .[] | reject(pc::member($pcs)) ]
;

def sdifference($pcs): #:: [number]|([number]) => [number]
    . as $pcset
    | difference($pcs) | union($pcs | difference($pcset))
;

def subset($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    inside($pcs)
;

def disjoint($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    intersection($pcs) == []
;

########################################################################
# Other pitch-class set operations

# Produces an inverted pitch-class set.
def invert($interval): #:: [number]|(number) => [number]
    # map(pc::invert($interval))
    [ .[] | pc::invert($interval) ]
;
def invert: #:: [number]| => [number]
    # map(pc::invert)
    [ .[] | pc::invert ]
;

# Produces a trasposed pitch-class set.
def transpose($interval): #:: [number]|(number) => [number]
    # map(pc::transpose($interval))
    [ .[] | pc::transpose($interval) ]
;

# Counts the number of transpositions for a pitch-class set.
def transpositions: #:: [number]| => number
#   . as $pcset
    12 / math::gcd(12; length)
;

# Format a pitch-class set as a string with , as delimiter
def format: #:: number| => string
#   . as $pcset
    [.[] | pc::format] | str::join(",") | "<\(.)>"
;

# Useful prmitives:
#   + reverse: (retrogradation)
#   + index($pc): (pclass position)
#   + map(pc::format) | str::join(""): to string

# vim:ai:sw=4:ts=4:et:syntax=jq
