module {
    name: "music/intervals",
    description: "Pitch-class sets intervals summaries",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

import "fadado.github.io/music/pitch-class" as pc;

########################################################################
# Names used in type declarations
#
# PCLASS (pitch-class): 0..11
# PCSET (pitch-class set): [PCLASS]
# IC (interval-class): 0..6
# PCI (pitch-class interval): 0..11
# PATTERN: [PCI]
# TABLE: [[number]] (indices are generic intervals minus 1; values are a list of specific intervals)

########################################################################
#

# Known as directed-interval vector, interval succession,  interval string, etc.
def pattern: #:: PCSET| => PATTERN
    . as $pcset
    | [range(length), 0] as $ndx
    | [range(length) as $i | $pcset[$ndx[$i]]|pc::interval($pcset[$ndx[$i+1]])]
#   | assert(add == 12)
;

# TODO: bip

########################################################################
#

# 
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

########################################################################
#

# 
def format: #:: [number]| => string
#   . as $a
    def fmt:
        ["0","1","2","3","4","5","6","7","8","9","A","B"][.]
    ;
    reduce (.[] | fmt) as $s (""; .+$s) # str::concat 
;

# vim:ai:sw=4:ts=4:et:syntax=jq
