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

import "fadado.github.io/generator" as stream;
import "fadado.github.io/generator/chance" as chance;

########################################################################
# Private auxiliar filters

# Pick one element, any
def _pick: #:: [α]| -> [α]
    .[0:1]
;

# What's _left after picking one element
def _left: #:: [α]| -> [α]
    .[1:]
;

# Pick the element at $i
def _pick($i): #:: [α]|(number) -> [α]
    .[$i:$i+1]
;

# What's _left after picking the element at $i
def _left($i): #:: [α]|(number) -> [α]
    del(.[$i])
;

########################################################################
# Sub-sets
########################################################################

# Subsets with one element removed (unsorted output)
#
def subset1_u: #:: [α]| -> <[α]>
    if length==0
    then empty
    else
        # either what's _left after picking one,
        _left
        # or this one with what's _left with one removed
        , _pick + (_left|subset1_u)
    end
;

# Size k subsets
# Combinations
#
def subset($k): #:: [α]|(number) -> <[α]>
    def _subset($k):
        if $k == 0
        then []
        elif length==0  # no results for k > n
        then empty
        else
            # either _pick one and add to what's _left subsets
            _pick + (_left|_subset($k-1))
            # or what's _left combined
            , (_left|_subset($k))
        end
    ;
    select(0 <= $k and $k <= length) # not defined for all $k
    | _subset($k)
;

# All subsets (powerset)

def subset: #:: [α]| -> <[α]>
    range(0; 1+length) as $n
    | subset($n)
;

# All subsets (unsorted output)
#
def subset_u: #:: [α]| -> <[α]>
    if length==0
    then []
    else
        # either what's _left after picking one,
        (_left|subset_u)
        # or this one added to what's _left subsets
        , _pick + (_left|subset_u)
    end
;

########################################################################
# Multi-sets
########################################################################

# Size k multisets
# Combinations with repetition
#
def mulset($k): #:: [α]|(number) -> <[α]>
    def _mulset($k):
        if $k == 0
        then []
        elif length==0
        then empty
        else
            # either _pick one and add to other multisets minus one
            _pick + _mulset($k-1)
            # or what's _left multisets
            , (_left|_mulset($k))
        end
    ;
    select(0 <= $k) # not defined for all $k
    | _mulset($k)
;

# Infinite multisets from a set
#
def mulset: #:: [α]| -> <[α]>
    mulset(range(0; infinite))
;

########################################################################
# Sub-sequences
########################################################################

# Permutations
#
def permutation: #:: [α]| -> <[α]>
    def choose: range(0; length); #:: -> <number>
    #
    if length==0
    then []
    else
        # choose one and add to what's _left permuted
        choose as $i
        | _pick($i) + (_left($i)|permutation)
    end
;

# All sizes permutations
#
def subseq: #:: [α]| -> <[α]>
    range(0; 1+length) as $k
    | subset($k)
    | permutation
;

# Partial permutations
#
def subseq($k): #:: [α]| -> <[α]>
    select(0 <= $k and $k <= length) # not defined for all $k
    | subset($k)
    | permutation
;

########################################################################
# Multi-sequences
########################################################################

# Cartesian product
#
def product: #:: [[α]]| <[α]>
    if length == 0
    then []
    else
        .[0][] as $x
        | (.[1:]|product) as $y
        | [$x] + $y
    end
;

# Infinite tuples from a set
# Infinite words over an alphabet
# All sizes permutations (variations) with repetition
#
def mulseq: #:: [α]| -> <[α]>
    # ordered version for:
    # def star(alphabet): "", (alphabet/"")[]+star(alphabet);
    #
    def choose: .[]; #:: [α]| -> <α>
    def _mulseq: #:: [α]| -> <[α]>
        # either the void sequence
        []
        # or add a sequence and an element from the set
        , _mulseq as $seq
        | choose as $element
        | $seq|.[length]=$element
    ;
    _mulseq
;

# Permutations (variations) with repetition
# Words over an alphabet
#
def mulseq($k): #:: [α]|(number) <[α]>
    select(0 <= $k) # not defined for all $k
    | . as $set
    | [range($k) | $set]
    | product
;

########################################################################
# Constricted permutations
########################################################################

# Derangements
#
def derangement: #:: [α]| -> <[α]>
    def choose($i): #:: [α]|(number) -> [[number,α]]
        range(length) as $j
        | if .[$j][0] == $i
          then empty
          else [$j, .[$j][1]]
          end
    ;
    def _derange($i): #:: [α]|(number) -> <[α]>
        if length == 0
        then []
        else
            # choose one valid for this "column"
            # and add to what's _left after removing this one deranged
            choose($i) as [$j, $x]
            | [$x] + (_left($j)|_derange($i+1))
        end
    ;
    if length < 2
    then empty  # no derangements for less than 2 elements
    else
        # . (dot) for _derange has still available enumerated elements
        [range(length) as $i | [$i,.[$i]]]
        | _derange(0)
    end
;

# Circular permutations (necklaces)
#
def circle_u: #:: [α]| -> <[α]>
    # expect sorted input
    .[-1] as $last
    | .[0:-1]|permutation
    | .[length]=$last
;

# Sorted necklaces (naïve implementation)
#
def circle: #:: [α]| -> <[α]>
    def rotate($min): #:: [α]| -> [α]
        if .[0] ==  $min
        then .
        else (.[-1:]+.[0:-1]) | rotate($min)
        end
    ;
    # expect sorted input
    .[0] as $first
    | [circle_u | rotate($first)]
    | sort[]
;

# Multi-set permutations (naïve implementation)
#
def arrangement: #:: [α]| -> <[α]>
    [permutation]
    | unique[]
;

# Multi-set combinations (naïve implementation)
#
def disposition: #:: [α]| -> <[α]>
    [subset]
    | unique
    | sort_by(length)[]
;

########################################################################
# Random choice
########################################################################

# Shuffles an array contents.
#
def shuffle($seed): #:: [α]|(number) -> [α]
    # Swaps two array positions
    def swap($i; $j): #:: [α]|(number;number) -> [α]
        if $i == $j
        then .
        else .[$i] as $t | .[$i]=.[$j] | .[$j]=$t
        end
    ;
    . as $array
    | length as $len
    | [stream::take($len; chance::rand($seed))] as $r
    # https://en.wikipedia.org/wiki/Fisher-Yates_shuffle
    # To shuffle an array a of n elements (indices 0..n-1)
    # for i from n−1 downto 1 do
    | reduce ($len - range(1; $len)) as $i ($array;
        # j ← random integer such that 0 ≤ j ≤ i
        ($r[$i] % ($i+1)) as $j
        # exchange a[j] and a[i]
        | swap($i; $j))
;
def shuffle: #:: [α] -> [α]
    shuffle(chance::randomize)
;

# Choose in order k random elements from the input array.
#
def take($k; $seed): #:: [α]|(number; number) -> <α>
    # Print in order k random elements from A[1]..A[n]
    # for (i=1; n>0; i++)
    #     if (rand() < k/n--) {
    #         print A[i]
    #         k--
    #     }
    def _take($a; $r; $m):
        def t($n; $k):
            ($m-$n) as $i
            | if $n < 1
              then empty
              elif $r[$i] < ($k/$n)
              then $a[$i] , t($n-1; $k-1)
              else t($n-1; $k)
              end
        ;
        t($m; $k)
    ;
    . as $a
    | length as $len
    | [stream::take($len; chance::rnd($seed))] as $r
    | _take($a; $r; $len)
;

def take($k): #:: [α]|(number) -> <α>
    take($k; chance::randomize)    
;

# vim:ai:sw=4:ts=4:et:syntax=jq
