module {
    name: "choice",
    description: "Combinatorial generators",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    },
    description: "Non-deterministic choice generators"
};

include "fadado.github.io/prelude";
import "fadado.github.io/array/set" as set;
import "fadado.github.io/generator/chance" as chance;
import "fadado.github.io/generator/chance" as chance;

########################################################################
# Private auxiliar filters

# Pick one element, any
def _pick: #:: [a]| => [a]
    .[0:1]
;

# What's left after picking one element
def _left: #:: [a]| => [a]
    .[1:]
;

# Pick the element at $i
def _pick($i): #:: [a]|(number) => [a]
    .[$i:$i+1]
;

# What's left after picking the element at $i
def _left($i): #:: [a]|(number) => [a]
    del(.[$i])
;

########################################################################
# Sub-sets
########################################################################

# Size (n-1) subsets
#
def subsets_1: #:: [a]| => *[a]
    if length == 0  # none to pick?
    then empty      # then fail
    else
        # either one picked with what's left with one removed
        _pick + (_left|subsets_1)
        # or  what's left after picking one
        , _left
    end
;

# Size k subsets
# Combinations
#
def combinations($k): #:: [a]|(number) => *[a]
    def _combs($k):
        if $k == 0
        then []
        elif length == 0 # none to pick?
        then empty       # then fail (no results for k > n)
        else
            # either _pick one and add to what's left combinations
            _pick + (_left|_combs($k-1))
            # or what's left combined
            , (_left|_combs($k))
        end
    ;
    select(0 <= $k and $k <= length) # not defined for all $k
    | _combs($k)
;

# All subsets, stable
#
def powerset: #:: [a]| => *[a]
    combinations(range(0; 1+length))
;

# All subsets, unstable output
#
def subsets: #:: [a]| => *[a]
    if length == 0
    then []
    else
        # or this one added to what's left subsets
        _pick + (_left|subsets)
        # either what's left after picking one,
        , (_left|subsets)
    end
;

########################################################################
# Sub-sequences
########################################################################

# Permutations
#
def permutations: #:: [a]| => *[a]
    def choose: range(0; length);
    #
    if length == 0
    then []
    else
        # choose one and add to what's left permuted
        choose as $i
        | _pick($i) + (_left($i)|permutations)
    end
;

# Partial permutations
# Variations
#
def permutations($k): #:: [a]|(number) => *[a]
    def _perm($k):
        def choose: # empty if none to choose
            range(0; length)
        ;
        if $k == 1
        then
            #choose as $i | _pick($i)
            .[] | [.]
        else
            # choose one and add to what's left permuted
            choose as $i
            | _pick($i) + (_left($i)|_perm($k-1))
        end
    ;
    select(0 <= $k and $k <= length) # not defined for all $k
    | if $k == 0 then [] else _perm($k) end
;

# All sizes permutations
#
def subseqs: #:: [a]| => *[a]
    permutations(range(0; 1+length))
;

########################################################################
# Multi-sets
########################################################################

# Size k multisets
# Combinations with reposition
#
def mulsets($k): #:: [a]|(number) => *[a]
    def _mulset($k):
        if $k == 0
        then []
        elif length == 0 # none to pick?
        then empty       # then fail
        else
            # either _pick one and add to other multisets minus one
            _pick + _mulset($k-1)
            # or what's left multisets
            , (_left|_mulset($k))
        end
    ;
    select(0 <= $k) # not defined for all $k
    | _mulset($k)
;

# Infinite multisets from a set
#
def mulsets: #:: [a]| => *[a]
    mulsets(range(0; infinite))
;

########################################################################
# Multi-sequences
########################################################################

#
# Alphabet
#

# Generates Σ*: Σ⁰ ∪ Σ¹ ∪ Σ² ∪ Σ³ ∪ Σ⁴ ∪ Σ⁵ ∪ Σ⁶ ∪ Σ⁷ ∪ Σ⁸ ∪ Σ⁹…
#
def kstar: #:: [a]| => +[a]
    . as $alphabet
    | if length == 0
    then []
    else []|deepen(set::insert($alphabet[]))
    end
;

# Generates Σ⁺: Σ¹ ∪ Σ² ∪ Σ³ ∪ Σ⁴ ∪ Σ⁵ ∪ Σ⁶ ∪ Σ⁷ ∪ Σ⁸ ∪ Σ⁹…
#
def kplus: #:: [a]| => *[a]
    . as $alphabet
    | if length == 0
    then empty
    else deepen1(set::insert($alphabet[]))
    end
;

# Size n words over an alphabet Σ (Σⁿ)
# Permutations (variations) with reposition
#
def words($n): #:: [a]|(number) => +[a]
#   . as $alphabet
    set::power($n)
;

# Infinite words over an alphabet Σ (Σ*: Σ⁰ ∪ Σ¹ ∪ Σ²…)
# All sizes permutations (variations) with reposition
#
def words: #:: [a]| => +[a]
#   . as $alphabet
    kstar
;

#
# Word
#

# Generates w*: w⁰ ∪ w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
#
def catenate: #:: [a]| => +[a]
    . as $word
    | []|iterate(. + $word)
;

# wⁿ
#
def catenate($n): #:: [a]|(number) => +[a]
    select(0 <= $n) # not defined for negative $n
    | . as $word
    | reduce range($n) as $_ ([]; . + $word)
;

#
# TODO: Language
#

def langs($n): #:: [a]|(number) => +[a]
#   . as $language
    set::power($n) | reduce .[] as $w ([]; .+$w)
;

########################################################################
# Constricted permutations
########################################################################

# Circular permutations (necklaces)
#
def cicles: #:: [a]| => *[a]
    _pick as $first
    | _left|permutations
    | $first + .
;

# Derangements
#
def derangement: #:: [a]| => *[a]
    def choose($i): #:: [a]|(number) => [[number,a]]
        range(length) as $j
        | select(.[$j][0] != $i)
        | [$j, .[$j][1]]
    ;
    def _derange($i): #:: [a]|(number) => *[a]
        if length == 0
        then []
        else
            # choose one valid for this "column"
            # and add to what's left after removing this one deranged
            choose($i) as [$j, $x]
            | [$x] + (_left($j)|_derange($i+1))
        end
    ;
    select(length >= 2) # no derangements for less than 2 elements
    # . (dot) for _derange has still available enumerated elements
    | [range(length) as $i | [$i,.[$i]]]
    | _derange(0)
;

########################################################################
# Random choice
########################################################################

# Shuffle array contents.
#
def shuffle($seed): #:: [a]|(number) => [a]
    # Swaps two array positions
    def swap($i; $j):
        when($i != $j;
             .[$i] as $t | .[$i]=.[$j] | .[$j]=$t)
    ;
    . as $array
    | length as $len
    | [stream::take($len; chance::rand($seed))] as $r
    # https://en.wikipedia.org/wiki/Fisher-Yates_shuffle
    # To shuffle an array a of n elements (indices 0..n-1)
    # for i from n−1 downto 1 do
    | reduce ($len - range(1; $len)) as $i
        ($array;
         # j ← random integer such that 0 ≤ j ≤ i
         ($r[$i] % ($i+1)) as $j
         # exchange a[j] and a[i]
         | swap($i; $j))
;
def shuffle: #:: [a]| => [a]
    shuffle(chance::randomize)
;

# Choose in order k random elements from the input array.
#
def take($k; $seed): #:: [a]|(number;number) => *a
    # Print in order k random elements from A[1]..A[n]
    # for (i=1; n>0; i++)
    #     if (rand() < k/n--) {
    #         print A[i]
    #         k--
    #     }
    def _take($a; $r; $m):
        def t($n; $k):
            if $n < 1
            then emtpy
            else
                ($m-$n) as $i
                | if $r[$i] < ($k/$n)
                then $a[$i] , t($n-1; $k-1)
                else t($n-1; $k)
                end
            end
        ;
        t($m; $k)
    ;
    . as $a
    | length as $len
    | [stream::take($len; chance::rnd($seed))] as $r
    | _take($a; $r; $len)
;

def take($k): #:: [a]|(number) => *a
    take($k; chance::randomize)    
;

########################################################################
# Multi-set permutations (naïve implementation)
#
#def arrangement: #:: [a]| => *[a]
#    [permutations]
#    | unique[]
#;

# Multi-set combinations (naïve implementation)
#
#def disposition: #:: [a]| => *[a]
#    [powerset]
#    | unique
#    | sort_by(length)[]
#;

# vim:ai:sw=4:ts=4:et:syntax=jq
