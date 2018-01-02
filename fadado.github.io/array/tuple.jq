module {
    name: "array/tuple",
    description: "Permutations on tuples",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    },
};

include "fadado.github.io/prelude";

########################################################################
# Types used in declarations:
#   TUPLE: [a]

# Permutations
#
def permutations: #:: TUPLE => *TUPLE
    def choose: range(0; length);
    #
    if length == 0
    then []
    else
        # choose one and add to what's left permuted
        choose as $i
        | .[$i:$i+1] + (del(.[$i])|permutations)
    end
;

# Partial permutations
# Variations
#
def permutations($k): #:: TUPLE|(number) => *TUPLE
    def _perm($k):
        def choose: # empty if none to choose
            range(0; length)
        ;
        if $k == 1
        then
            #choose as $i | .[$i:$i+1]
            .[] | [.]
        else
            # choose one and add to what's left permuted
            choose as $i
            | .[$i:$i+1] + (del(.[$i])|_perm($k-1))
        end
    ;
    select(0 <= $k and $k <= length) # not defined for all $k
    | if $k == 0 then [] else _perm($k) end
;

# All sizes permutations
#
def subseqs: #:: TUPLE => *TUPLE
    permutations(range(0; 1+length))
;

# Circular permutations (necklaces)
#
def cicles: #:: TUPLE => *TUPLE
    .[0:1] as $first
    | .[1:]|permutations
    | $first + .
;

# Derangements
#
def derangement: #:: TUPLE => *TUPLE
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
            | [$x] + (del(.[$j])|_derange($i+1))
        end
    ;
    select(length >= 2) # no derangements for less than 2 elements
    # . (dot) for _derange has still available enumerated elements
    | [range(length) as $i | [$i,.[$i]]]
    | _derange(0)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
