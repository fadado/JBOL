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

# directed-interval vector, also interval string
def pattern: #:: PCSET| => [PCI]
    . as $pcset
    | [range(length), 0] as $ndx
    | [
        range(length) as $i
        | $pcset[$ndx[$i]]
        | pc::interval($pcset[$ndx[$i+1]])
      ]
#   | assert(add == 12)
;

# Interval-class tally vector
def vector: #:: PCSET => [number]
    def intervals:
        . as $pcs
        | length as $n
        | range($n-1) as $i
        | range($i+1; $n) as $j
#       | ($j - $i) as $d
#       | $pcs[$i]|pc::interval($pcs[$j]) as $c
#       | $c|pc::interval_class
        | $pcs[$i]|pc::interval_class($pcs[$j])
    ;
    # interval class vector with cardinality at .[0]
    [length,0,0,0,0,0,0] as $icv
    | reduce intervals as $i ($icv; .[$i] += 1)
    # use $v[1:] to extract traditional interval vector
;

# Format intervals array 
def format: #:: [number]| => string
#   . as $a
    def fmt:
        ["0","1","2","3","4","5","6","7","8","9","A","B"][.]
    ;
    reduce (.[] | fmt) as $s (""; .+$s) # str::concat 
;

# vim:ai:sw=4:ts=4:et:syntax=jq
