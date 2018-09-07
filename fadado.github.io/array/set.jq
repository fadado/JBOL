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
# Types used in declarations:
#   SET:    [a]
#   MULSET: [a]

########################################################################
# Basic algebra of sets

# ∅         []
# |S|       length
# {x...}    [x...]
# {x...}    [x...] | unique
# S ⊂ T     S|inside(T)
# S ⊃ T     S|contains(T)
# S – T     S - T

# s + e (add element to set)
def insert($x): #:: SET|(a) => SET
    when(indices($x) == []; .[length] = $x)
;

# s – e (remove one element from set)
# Use array::remove/1 to remove all `x`
def remove($x): #:: SET|(a) => SET
    indices($x)[0] as $i
    | when($i != null; del(.[$i]))
;

# x ∈ S (x is element of S?)
def element($s): #:: a|(SET) => boolean
    [.] | inside($s)
;

# S ∋ x (S contains x as member?)
def member($x): #:: SET|(a) => boolean
    contains([$x])
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
# Subsets

# Size (n-1) subsets
# M(n) = n
def minus1: #:: SET => *SET
    if length == 0  # none to pick?
    then empty      # then fail
    else
        range(length-1;-1;-1) as $i
        | del(.[$i])
# Alternative compatible with strings
#       # either pick first and add to what's left with one removed
#       .[0:1] + (.[1:]|minus1)
#       # or  what's left after picking the first
#       , .[1:]
    end
;

# Size k subsets, Combinations
# C(n,k) = P(n,k)/P(k) = (n!/(n-k)!)/k! = n!/((n-k)!k!)
# C(n,n) = C(n,0) = 1
# C(n,k) = 0 for k > n
def combinations($k): #:: SET|(number) => *SET
    def _combs($k):
        if $k == 0
        then []
        elif length == 0 # none to pick?
        then empty       # then fail (no results for k > n)
        else
            # either pick one and add to what's left combinations
            .[0:1] + (.[1:]|_combs($k-1))
            # or what's left combined
            , (.[1:]|_combs($k))
        end
    ;
    select(0 <= $k and $k <= length) # not defined for all $k
    | _combs($k)
;

# All subsets, stable
# S(n) = 2^n
def powerset: #:: SET => +SET
    combinations(range(0;length+1))
;

# All subsets, unstable output
def powerset_u: #:: SET => +SET
    if length == 0
    then []
    else
        (.[1:]|powerset_u) as $s
        | $s , .[0:1]+$s
    end
;

########################################################################
# Multisets

# Size k multisets, Combinations with reposition
# M(n,k) = C(n+k-1,k) = (n+k-1)!/(k!(n-1)!)
def mulsets($k): #:: SET|(number) => *MULSET
    def _mulset($k):
        if $k == 0
        then []
        elif length == 0 # none to pick?
        then empty       # then fail
        else
            # either pick one and add to other multisets minus one
            .[0:1] + _mulset($k-1)
            # or what's left multisets
            , (.[1:]|_mulset($k))
        end
    ;
    select(0 <= $k) # not defined for all $k
    | _mulset($k)
;

# Infinite multisets from a set
def mulsets: #:: SET => *MULSET
    mulsets(seq)
;

# Multiset permutations (naïve implementation)
#def arrangement: #:: [a] => *[a]
#    [permutations]
#    | unique[]
#;

# Multiset combinations (naïve implementation)
#def disposition: #:: [a] => *[a]
#    [powerset]
#    | unique
#    | sort_by(length)[]
#;

# vim:ai:sw=4:ts=4:et:syntax=jq
