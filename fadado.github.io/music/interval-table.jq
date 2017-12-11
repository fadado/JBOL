module {
    name: "music/interval-table",
    description: "Intervals table",
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
# TABLE: [[PCI]]

########################################################################
# pitch-class step/size table

# indices: generic intervals - 1
# values:  a list of specific intervals
def new: #:: PCSET => TABLE
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
#   define myhill, maximally_even

# vim:ai:sw=4:ts=4:et:syntax=jq
