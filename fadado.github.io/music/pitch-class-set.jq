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

# Produces the pitch-class set
def new: #:: <array^string>| => PCSET
    if type == "array"
    then
        unique | map(pc::new)
    elif type == "string" then
        fromjson
    else type | "Type error: expected array or string, not \(.)" | error
    end
;
def new($x): #::(<array^string>) => PCSET
    $x | new
;

# Format a pitch-class set as a string with , as delimiter
def format: #:: PCSET| => string
#   . as $pcset
    reduce (.[] | pc::format) as $s (""; .+$s) # str::concat 
;

########################################################################

# Produces a trasposed pitch-class set.
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
# pure set operations

# pcs ∋ pc (pcs contains pc as member)
def member($pclass): #:: PCSET|(PCLASS) => boolean
#   . as $pcset
    contains([$pclass])
;

# ~p
def complement: #:: PCSET| => PCSET
    . as $pcset
    | [ range(12) | reject(pc::element($pcset)) ]
;

# p ∪ q
def union($pcs): #:: PCSET|(PCSET) => PCSET
#   . as $pcset
    . + $pcs | unique
;

# p ∩ q
def intersection($pcs): #:: PCSET|(PCSET) => PCSET
#   . as $pcset
    map(select(pc::element($pcs)))
;

# p – q
def difference($pcs): #:: PCSET|(PCSET) => PCSET
#   . as $pcset
    map(reject(pc::element($pcs)))
;

# (p – q) ∪ (q – p)
def sdifference($pcs): #:: PCSET|(PCSET) => PCSET
    . as $pcset
    | difference($pcs) | union($pcs | difference($pcset))
;

# p ⊂ q
def subset($pcs): #:: PCSET|(PCSET) => boolean
#   . as $pcset
    inside($pcs)
;

# p ⊃ q
def superset($pcs): #:: PCSET|(PCSET) => boolean
#   . as $pcset
    contains($pcs)
;

#  p ∩ q ≡ ∅
def disjoint($pcs): #:: PCSET|(PCSET) => boolean
#   . as $pcset
    intersection($pcs) == []
;

########################################################################
# TODO: nomal, prime...

# vim:ai:sw=4:ts=4:et:syntax=jq
