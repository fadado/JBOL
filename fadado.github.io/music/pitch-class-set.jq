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


# Format a pitch-class set as a string with , as delimiter
def format: #:: [number]| => string
#   . as $pcset
    map(pc::format) | str::concat 
;

# Useful primitives:
#   + fromjson/tojson
#   + reverse: (retrogradation)
#   + position: index($pc)
#   + str::rotate (rotation)

########################################################################

# pcs ∋ pc
def holds($pclass): #:: [number]|(number) => boolean
#   . as $pcset
    contains([$pclass])
;

# ~p
def complement: #:: [number]| => [number]
    . as $pcset
    | [ range(12) | reject(pc::member($pcset)) ]
;

# p ∪ q
# TODO: an ordered merge without duplicates?
def union($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    . + $pcs | unique
;

# p ∩ q
def intersection($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    map(select(pc::member($pcs)))
;

# p – q
def difference($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    map(reject(pc::member($pcs)))
;

# (p – q) ∪ (q – p)
def sdifference($pcs): #:: [number]|([number]) => [number]
    . as $pcset
    | difference($pcs) | union($pcs | difference($pcset))
;

# p ⊂ q
def subset($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    inside($pcs)
;

#  p ∩ q ≡ ∅
def disjoint($pcs): #:: [number]|([number]) => [number]
#   . as $pcset
    intersection($pcs) == []
;

########################################################################
# Other pitch-class set operations

# Produces an inverted pitch-class set.
def invert($interval): #:: [number]|(number) => [number]
    map(pc::invert($interval))
;
def invert: #:: [number]| => [number]
    map(pc::invert)
;

# Produces a trasposed pitch-class set.
def transpose($interval): #:: [number]|(number) => [number]
    map(pc::transpose($interval))
;

# Counts the number of transpositions for a pitch-class set.
def transpositions: #:: [number]| => number
#   . as $pcset
    12 / math::gcd(12; length)
;

########################################################################
# Intervals

def mode: #:: [number]| => string
    . as $pcset
    | [range(length), 0] as $ndx
    | [
        range(length) as $i
        | $pcset[$ndx[$i]]
        | pc::interval($pcset[$ndx[$i+1]])
      ]
#   assert(add) == 12
;

# vim:ai:sw=4:ts=4:et:syntax=jq
