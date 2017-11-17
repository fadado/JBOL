module {
    name: "array",
    description: "Generic array operations",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

########################################################################

# First index inside set
def position($x):
    .[[$x]][0]
;

# Rotate in both directions
def rotate($n): #:: array|(number) => array
    .[$n:] + .[:$n]
;
def rotate: #:: array => array
    .[1:] + .[:1]
;

# Is the array sorted?
def sorted: #:: array| => boolean
    every(
        range(length-1) as $i
        | ($i+1) as $j
        | .[$i] <= .[$j])
;

# All elements are equal?
def uniform: #:: array => boolean
    every(
        range(0; length-1) as $i
        | ($i+1) as $j
        | .[$i] == .[$j])
;

# All elements are diferent?
def different: #:: array => boolean
    every(
        range(0; length-1) as $i
        | range($i+1; length) as $j
        | .[$i] != .[$j])
;


# vim:ai:sw=4:ts=4:et:syntax=jq
