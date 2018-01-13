module {
    name: "array/choice",
    description: "Randon tuple choice",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    },
};

include "fadado.github.io/prelude";
import "fadado.github.io/math/chance" as chance;

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
    | [limit($len; chance::rand($seed))] as $r
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
def shuffle: #:: [a] => [a]
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
            then empty
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
    | [limit($len; chance::rnd($seed))] as $r
    | _take($a; $r; $len)
;

def take($k): #:: [a]|(number) => *a
    take($k; chance::randomize)    
;

# vim:ai:sw=4:ts=4:et:syntax=jq
