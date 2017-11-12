module {
    name: "music/pitch-class-sequence",
    description: "Pitch-class sets considered as sequences",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/music/pitch-class" as pc;

########################################################################
# Names used in type declarations
#
# PCLASS (pitch-class): 0..11
# PCI (pitch-class interval): 0..11
# PCSET (pitch-class set): [PCLASS]
# TABLE: [[PCI]]
# PATTERN: [PCI]

# pitch-class index inside pcset
def position($pclass): #:: PCSET|(PCLASS) => number^null
    index($pclass)
;

# Is the pcset an ordered sequence?
def ordered: #:: PCSET| => boolean
#   . as $pcset
    every(
        range(length-1) as $i
        | ($i+1) as $j
        | .[$i] <= .[$j])
;

# Rotate in both directions
def rotate($n): #:: PCSET|(number) => PCSET
    .[$n:] + .[:$n]
;

# Simply reverse sequence
def retrograde: #:: PCSET => PCSET
    reverse
;

########################################################################
# pitch-class step/size table

# indices: generic intervals - 1
# values:  a list of specific intervals
def table: #:: PCSET => TABLE
    def _table:
        . as $pcs
        | length as $n
        | range($n-1) as $i
        | range($i+1; $n) as $j
        | ($j - $i) as $d
        | $pcs[$i]|pc::interval($pcs[$j]) as $c
        | ([$d,$c], [$n-$d,12-$c])
    ;
    [range(length-2)|[]] as $t
    | reduce _table as [$d,$c] ($t; .[$d-1] += [$c])
    | map(unique)
;

# TODO
#   move to step-size-table.jq
#   define myhill, maximally_even

########################################################################
# Intervals succession pattern
# Known as directed-interval vector, interval succession,  interval string,
# etc.

def pattern: #:: PCSET| => PATTERN
    . as $pcset
    | [range(length), 0] as $ndx
    | [range(length) as $i | $pcset[$ndx[$i]]|pc::interval($pcset[$ndx[$i+1]])]
#   | assert(add == 12)
;

# TODO
#   move to interval-pattern.jq
#   define bip

# vim:ai:sw=4:ts=4:et:syntax=jq
