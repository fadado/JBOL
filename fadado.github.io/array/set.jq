module {
    name: "array/set",
    description: "Arrays as sets",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

########################################################################
# Basic algebra of sets

# ∅         []
# |S|       length
# {x...}    [x...]
# {x...}    [x...] | unique
# S ⊂ T     S|contains(T)
# S ⊃ T     S|inside(T)
# S – T     S - T

# s + e (add element to set)
def insert($x): #:: [a]|(a) => [a]
    .[length] = $x
;

# s – e (remove element from set)
def remove($x): #:: [a]|(a) => [a]
    .[[$x]][0] as $i
    | when($i != null; del(.[$i]))
;

# x ∈ S (x is element of S?)
def element($s): #:: a|([a]) => boolean
    $s[[.]] != []
;

# S ∋ x (S contains x as member?)
def member($x): #:: a|([a]) => boolean
    .[[$x]] != []
;

# S ≡ T (S is equal to T?)
def equal($t): #:: [a]|([a]) => boolean
    inside($t) and contains($t)
;

#  S ∩ T ≡ ∅ (no common element?)
def disjoint($t): #:: array|(array) => boolean
    . - (. - $t) == []
;

# S ∪ T
def union($t): #:: array|(array) => array
    . + ($t - .)
# Also:
#   (. + $t) | unique
;

# S ∩ T
def intersection($t): #:: array|(array) => array
    . - (. - $t)
;

# (S – T) ∪ (T – S)
def sdifference($t): #:: array|(array) => array
    (. - $t) + ($t - .)
;

########################################################################
# Cartesian product

# A × B; A × B × C; etc.
def product: #:: [[a]]| => *[a]
#   . as $set
    def _product:
        if length == 1
        then
            .[0][] | [.]
        else
            .[0][] as $x
            | [$x] + (.[1:]|_product)
        end
    ;
    if length < 2
    then []
    else _product // []
    end
;
def product($A;$B): [$A,$B]|product;
def product($A;$B;$C): [$A,$B,$C]|product;
def product($A;$B;$C;$D): [$A,$B,$C,$D]|product;
def product($A;$B;$C;$D;$E): [$A,$B,$C,$D,$E]|product;
def product($A;$B;$C;$D;$E;$F): [$A,$B,$C,$D,$E,$F]|product;
def product($A;$B;$C;$D;$E;$F;$G): [$A,$B,$C,$D,$E,$F,$G]|product;

# A⁰; A¹; A²; … Aⁿ
def power($n): #:: [a]|(number) => *[a]
#   . as $set
    select(0 <= $n) # not defined for negative $n
    | if $n == 0
    then []
    elif $n == 1
    then .
    else
        . as $set
        | [range($n) | $set]
        | product
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
