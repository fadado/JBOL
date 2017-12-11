module {
    name: "music/interval-class-vector",
    description: "Interval-class count vector",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/array" as array;
import "fadado.github.io/math" as math;
import "fadado.github.io/music/pitch-class" as pc;

########################################################################
# Names used in type declarations
#
# PCLASS (pitch-class): 0..11
# PCSET (pitch-class set): [PCLASS]
# IC (interval-class): 0..6
# VECTOR: 6[number]; indices are IC-1

# Interval-class vector
def new: #:: PCSET => VECTOR
    def _tally:
        . as $pcs
        | length as $n
        | range($n-1) as $i
        | range($i+1; $n) as $j
        | $pcs[$i]|pc::interval_class($pcs[$j])
    ;
    # interval class vector
    reduce _tally as $interval_class
        ([0,0,0,0,0,0]; .[$interval_class-1] += 1)
;
def new($pcs):  #:: (PCSET) => VECTOR
    $pcs | new
;

# Hexadecimal format
def format: #:: VECTOR => string
    add(.[] | math::tobase(16); "")
;

# Howard Hanson format
def name: #:: VECTOR => string
    . as $v # vector
    | ["d","s","n","m","p","t"] as $n # name
    | ["⁰","¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹","¹⁰","¹¹","¹²"] as $d # digit
    | reduce (
        (4,3,2,1,0,5) as $i
        | $v[$i]
        | if . == 0
          then empty
          elif . == 1
          then $n[$i]
          else $n[$i] , $d[.] end
      ) as $s (""; . + $s)
;

# Multiplicity of interval-class in one pitch-class set
def multiplicity($i): #:: VECTOR|(IC) => number
    .[$i-1]
;

#  Deep scale property
def deep_scale: #:: VECTOR => boolean
    array::different
;

# vim:ai:sw=4:ts=4:et:syntax=jq
