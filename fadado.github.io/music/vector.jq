module {
    name: "music/vector",
    description: "Interval class vector",
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
# PCSET (pitch-class set): [PCLASS]
# IC (interval-class): 0..6
# VECTOR: [number]7

# Interval-class vector including unisons (= cardinality)
def new: #:: PCSET => VECTOR
    def _tally:
        . as $pcs
        | length as $n
        | range($n-1) as $i
        | range($i+1; $n) as $j
        | $pcs[$i]|pc::interval_class($pcs[$j])
    ;
    # interval class vector with cardinality at .[0]
    [length,0,0,0,0,0,0] as $icv
    | reduce _tally as $i ($icv; .[$i] += 1)
;

# Format intervals array 
def format: #:: VECTOR => string
#   . as $vector
    def fmt:
        ["0","1","2","3","4","5","6","7","8","9","A","B"][.]
    ;
    reduce (.[] | fmt) as $s (""; .+$s) # str::concat 
;

# All counts are equal?
def uniform: #:: VECTOR => boolean
#   . as $vector
    every(
        range(1; length) as $i
        | .[$i] == .[$i-1])
;

# All counts are diferent? Deep scale property.
def different: #:: VECTOR => boolean
#   . as $vector
    every(
        range(length) as $i
        | range($i+1; length) as $j
        | .[$i] != .[$j])
;

# vim:ai:sw=4:ts=4:et:syntax=jq
