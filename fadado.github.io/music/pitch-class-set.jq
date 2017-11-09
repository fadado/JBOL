module {
    name: "music/pitch-class-set",
    description: "Pitch-class sets functions",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

import "fadado.github.io/math" as math;
import "fadado.github.io/music/pitch-class" as pc;

########################################################################
# Names used in type declarations
#
# PCLASS (pitch-class): 0..11
# PCI (pitch-class interval): -11..11
# PCSET (pitch-class set): [PCLASS]

# Produces the pitch-class set
def new: #:: <array^string>| => PCSET
    if type == "array"
    then
        unique
    elif type == "string" then
        fromjson
    else type | "Type error: expected array or string, not \(.)" | error
    end
;

# Format a pitch-class set as a string with , as delimiter
def format: #:: PCSET| => string
#   . as $pcset
    map(pc::format) | reduce .[] as $s (""; .+$s) # str::concat 
;

########################################################################
# set operations

# pcs ∋ pc
def member($pclass): #:: PCSET|(PCLASS) => boolean
#   . as $pcset
    contains([$pclass])
;

def position($pclass): #:: PCSET|(PCLASS) => number^null
    index($pclass)
;

# ~p
def complement: #:: PCSET| => PCSET
    . as $pcset
    | [ range(12) | select(pc::element($pcset)|not) ]
;

# p ∪ q
# TODO: an ordered merge without duplicates?
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
    map(select(pc::element($pcs))|not)
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

#  p ∩ q ≡ ∅
def disjoint($pcs): #:: PCSET|(PCSET) => boolean
#   . as $pcset
    intersection($pcs) == []
;

########################################################################
# Other pitch-class set operations

# Produces an inverted pitch-class set.
# TODO:
def invert($axis): #:: PCSET|(PCLASS) => PCSET
    map(pc::invert($axis))
;
def invert: #:: PCSET| => PCSET
    map(pc::invert)
;

# Produces a trasposed pitch-class set.
def transpose($interval): #:: PCSET|(PCI) => PCSET
    map(pc::transpose($interval))
;

# Counts the number of transpositions for a pitch-class set.
def transpositions: #:: PCSET| => number
#   . as $pcset
    12 / math::gcd(12; length)
;

def rotate($n): #:: PCSET|(number) => PCSET
    .[$n:] + .[:$n]
;

def retrograde: #:: PCSET => PCSET
    reverse
;

# vim:ai:sw=4:ts=4:et:syntax=jq
