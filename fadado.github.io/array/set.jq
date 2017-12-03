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

# (×), A × B, A × B × C, …
def product: #:: [[a]]| => +[a]
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
    if length == 0
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

# Aⁿ
# Specifically size n words over an alphabet Σ (Σⁿ)
def power($n): #:: [a]|(number) => +[a]
#   . as $set
    select(0 <= $n) # not defined for negative $n
    | . as $set
    | [range($n) | $set]
    | product
;

########################################################################
# Kleene closures

# Generates K*: K⁰ ∪ K¹ ∪ K² ∪ K³ ∪ K⁴ ∪ K⁵ ∪ K⁶ ∪ K⁷ ∪ K⁸ ∪ K⁹…
# Specifically, words over an alphabet Σ (Σ*: Σ⁰ ∪ Σ¹ ∪ Σ²…)
#
def kstar: #:: [a]| => +[a]
    . as $set
    | if length == 0
    then []
    else deepen([]; .[length]=$set[])
    end
;

# Generates K⁺: K¹ ∪ K² ∪ K³ ∪ K⁴ ∪ K⁵ ∪ K⁶ ∪ K⁷ ∪ K⁸ ∪ K⁹…
# Specifically, words over an alphabet Σ without empty word (Σ⁺: Σ¹ ∪ Σ²…)
#
def kplus: #:: [a]| => *[a]
    . as $set
    | if length == 0
    then empty
    else deepen(.[]|[.]; .[length]=$set[])
#   else deepen($set[]|[.]; .[length]=$set[])
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
