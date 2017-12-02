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

# Remove all x from array
def remove($x): #:: [a]|(a) => [a]
    .[[$x]] as $ix
    | when($ix != []; del(.[$ix[]]))
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

# Are all elements equal?
def uniform: #:: array => boolean
    every (
        range(0; length-1) as $i
        | ($i+1) as $j
        | .[$i] == .[$j])
;

# Are all elements diferent?
def different: #:: array => boolean
    every(
        range(0; length-1) as $i
        | range($i+1; length) as $j
        | .[$i] != .[$j])
;

########################################################################
#  Stack operations

def push($x): #:: [a]|(a) => [a]
    .[length] = $x
;
def pop: #:: [a] => [a]
    .[:-1]
;
def top: #:: [a] => a^null
    .[-1]
;

########################################################################

# Find "words"
def find($a): #:: [a]|([a]) => *number
    .[$a][]
;

# Find "symbols"
def upto($a): #:: [a]|([a]) => *number
    [find($a[]|[.])] | sort[]
;

# vim:ai:sw=4:ts=4:et:syntax=jq
