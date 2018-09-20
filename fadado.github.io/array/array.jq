module {
    name: "array",
    description: "Generic and stack array operations",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

########################################################################

# Remove all x from array
# Use set::remove/1 to remove only one `x`
def remove($x): #:: [a]|(a) => [a]
    indices($x) as $ix
    | when($ix != []; del(.[$ix[]]))
;

# Is the array sorted?
def sorted: #:: [a] => boolean
    every(
        range(0;length-1) as $i
        | ($i+1) as $j
        | .[$i] <= .[$j])
;

# Are all elements equal?
def uniform: #:: [a] => boolean
    every (
        range(0;length-1) as $i
        | ($i+1) as $j
        | .[$i] == .[$j])
;

# Are all elements diferent?
def different: #:: [a] => boolean
    every(
        range(0;length-1) as $i
        | range($i+1; length) as $j
        | .[$i] != .[$j])
;

# unknown value for index?
def unknown($i): #:: array|(number) => boolean
    has($i) and .[$i] == null
;

########################################################################
#  Stack operations

def push($x): #:: [a]|(a) => [a]
    .[length] = $x
;

def pop: #:: [a] => [a]
    del(.[-1]) # [] if empty
;

def top: #:: [a] => a^null
    .[-1] # null if empty
;

#
# Not optimized `zip` => def zip($a; $b): [$a, $b] | transpose[];
#

#
def zip($a; $b): #:: ([a];[b]) => *[a,b]
    [$a, $b] as $pair
    | ($pair | map(length) | max) as $longest
    | range($longest) | [$pair[0][.], $pair[1][.]]
;

# Generalized `zip` for 2 or more arrays.
#
def zip: #:: [[a],[b]...]| => *[a,b,...]
    . as $in
    | (map(length) | max) as $longest
    | length as $n
    | foreach range($longest) as $j (null;
        reduce range($n) as $i
            ([]; . + [$in[$i][$j]]))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
