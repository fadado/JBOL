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
import "fadado.github.io/generator/stream" as stream;
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
def subsets($k): #:: [a]|(number) => *[a]
    def _subsets($k):
        if $k == 0
        then []
        elif length == 0 # none to pick?
        then empty       # then fail (no results for k > n)
        else
            # either _pick one and add to what's left subsets
            _pick + (_left|_subsets($k-1))
            # or what's left combined
            , (_left|_subsets($k))
        end
    ;
    select(0 <= $k and $k <= length) # not defined for all $k
    | _subsets($k)
;

# All subsets
#
def powerset: #:: [a]| => *[a]
    subsets(range(0; 1+length))
;

# All subsets, unstable output
#
def powerset_u: #:: [a]| => *[a]
    if length == 0
    then []
    else
        # either what's left after picking one,
        (_left|powerset_u)
        # or this one added to what's left subsets
        , _pick + (_left|powerset_u)
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

# Partial permutations (unstable output)
# Variations
#
def permutations_u($k): #:: [a]| => *[a]
    select(0 <= $k and $k <= length) # not defined for all $k
    | subsets($k)
    | permutations
;

# All sizes permutations (unstable output)
#
def subseq_u: #:: [a]| => *[a]
    powerset | permutations
;

########################################################################
# Multi-sets
########################################################################

# Size k multisets
# Combinations with reposition
#
def mulset($k): #:: [a]|(number) => *[a]
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
def mulset: #:: [a]| => *[a]
    mulset(range(0; infinite))
;

########################################################################
# Multi-sequences
########################################################################

# Cartesian product
#
def product: #:: [[a]]| => *[a]
    if length == 0
    then []
    else
        first[] as $x
        | (_left|product) as $y
        | [$x] + $y
    end
;

# Permutations (variations) with reposition
# Words over an alphabet
#
def words($k): #:: [a]|(number) => *[a]
    select(0 <= $k) # not defined for negative $k
    | . as $set
    | [range($k) | $set]
    | product
;

# Infinite tuples from a set
# Infinite words over an alphabet
# All sizes permutations (variations) with reposition
#
def words: #:: [a]| => *[a]
    # ordered version for:
    #   def k: [], (.[]|[.]) + k;
    def choose: .[];
    def _mulseq:
        [] # either the void sequence
        ,  # or add a sequence and an element from the set
        _mulseq as $seq
        | choose as $element
        | $seq|.[length]=$element
    ;
    if length == 0 then . else _mulseq end
;

########################################################################
# Constricted permutations
########################################################################

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

# Circular permutations (necklaces)
#
def cicles: #:: [a]| => *[a]
    .[-1] as $last
    | .[0:-1]|permutations
    | .[length]=$last
;

# Sorted necklaces (naïve implementation)
#
def cicles_canonical: #:: [a]| => *[a]
    def rotate($min): #:: [a]| => [a]
        when(.[0] != $min;
             .[-1:]+.[0:-1] | rotate($min))
    ;
    # expect sorted input
    .[0] as $first
    | [cicles | rotate($first)]
    | sort[]
;

# Multi-set permutations (naïve implementation)
#
def arrangement: #:: [a]| => *[a]
    [permutations]
    | unique[]
;

# Multi-set combinations (naïve implementation)
#
def disposition: #:: [a]| => *[a]
    [powerset]
    | unique
    | sort_by(length)[]
;

########################################################################
# Random choice
########################################################################

# Shuffles an array contents.
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

# vim:ai:sw=4:ts=4:et:syntax=jq
