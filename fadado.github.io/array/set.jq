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

# Types used in declarations:
#   SET: [a]

# ∅         []
# |S|       length
# {x...}    [x...]
# {x...}    [x...] | unique
# S ⊂ T     S|contains(T)
# S ⊃ T     S|inside(T)
# S – T     S - T

# s + e (add element to set)
def insert($x): #:: SET|(a) => SET
    .[length] = $x
;

# s – e (remove element from set)
def remove($x): #:: SET|(a) => SET
    indices($x)[0] as $i
    | when($i != null; del(.[$i]))
;

# x ∈ S (x is element of S?)
def element($s): #:: a|(SET) => boolean
    . as $e | $s|indices($e) != []
;

# S ∋ x (S contains x as member?)
def member($x): #:: a|(SET) => boolean
    indices($x) != []
;

# S ≡ T (S is equal to T?)
def equal($t): #:: SET|(SET) => boolean
    inside($t) and contains($t)
;

#  S ∩ T ≡ ∅ (no common element?)
def disjoint($t): #:: SET|(SET) => boolean
    . - (. - $t) == []
;

# S ∪ T
def union($t): #:: SET|(SET) => SET
    . + ($t - .)
# Also:
#   (. + $t) | unique
;

# S ∩ T
def intersection($t): #:: SET|(SET) => SET
    . - (. - $t)
;

# (S – T) ∪ (T – S)
def sdifference($t): #:: SET|(SET) => SET
    (. - $t) + ($t - .)
;

########################################################################
# Cartesian product

# Types used in declarations:
#   SET: [a]
#   TUPLE: [a]
# For operations with concatenable symbols:
#   IDENTITY: "" or []
#   SYMBOL: [a]^string  -- catenable symbol

# (×), A × B, A × B × C, …
# Generates tuples (using arrays)
def product: #:: [SET] => +TUPLE
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

# For sets with catenable symbols (arrays or strings)
# Note: empty array or string must be specified as identity value
def product($identity): #:: [SET]|(IDENTITY) => +SYMBOL
#   . as $set
    def _product:
        if length == 1
        then
            .[0][]
        else
            .[0][] as $x
            | $x + (.[1:]|_product)
        end
    ;
    if length == 0
    then $identity
    else _product // $identity
    end
;

# Aⁿ
# Specifically size n words over an alphabet Σ (Σⁿ)
def power($n): #:: SET|(number) => +TUPLE
#   . as $set
    select(0 <= $n) # not defined for negative $n
    | . as $set
    | [range($n) | $set]
    | product
;

def power($n; $identity): #:: SET|(number;IDENTITY) => +SYMBOL
#   . as $set
    select(0 <= $n) # not defined for negative $n
    | . as $set
    | [range($n) | $set]
    | product($identity)
;

########################################################################
# Kleene closures

# Generates K*: K⁰ ∪ K¹ ∪ K² ∪ K³ ∪ K⁴ ∪ K⁵ ∪ K⁶ ∪ K⁷ ∪ K⁸ ∪ K⁹…
# Specifically, words over an alphabet Σ (Σ*: Σ⁰ ∪ Σ¹ ∪ Σ²…)
#
def kstar: #:: SET => +TUPLE
    . as $set
    | if length == 0
    then []
    else deepen([]; .[length]=$set[])
    end
;

# For catenable symbols
def kstar($identity): #:: SET|(IDENTITY) => +SYMBOL
    . as $set
    | if length == 0
    then $identity
    else deepen($identity; . + $set[])
    end
;

# Generates K⁺: K¹ ∪ K² ∪ K³ ∪ K⁴ ∪ K⁵ ∪ K⁶ ∪ K⁷ ∪ K⁸ ∪ K⁹…
# Specifically, words over an alphabet Σ without empty word (Σ⁺: Σ¹ ∪ Σ²…)
#
def kplus: #:: SET => *TUPLE
    . as $set
    | if length == 0
    then empty
    else deepen(.[]|[.]; .[length]=$set[])
#   else deepen($set[]|[.]; .[length]=$set[])
    end
;

# For catenable symbols ($identity is not used!)
def kplus($identity): #:: SET|(IDENTITY) => *SYMBOL
    . as $set
    | if length == 0
    then empty
    else deepen(.[]; . + $set[])
    end
;

########################################################################

# Alphabet Σ:                   [a,b,c,...] (a set)
# Σ*:                           Σ | kstar
# Σ⁺:                           Σ | kplus
# Σⁿ:                           Σ | power(n)

# Word w:                       [...] or "..."

# Language L over Σ:            [w,u...]    (a set of words)
# L1 × L2:                      [L1,l2] | product([] or "")
# L*:                           L | kstar([] or "")
# L⁺:                           L | kplus([] or "")
# Lⁿ:                           L | power(n; [] or "")

# vim:ai:sw=4:ts=4:et:syntax=jq
