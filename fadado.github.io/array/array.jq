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
# Combinatorics on Words

# Alphabet:                     [...]
# Word:                         [...]
# Language:                     [[w],[u]...]
# Length of a word:             w|length
# Number of symbols in a word:  w|unique|length
# Alphabet of a word:           w|unique
# Catenation:                   w + u
# Reverse of a word:            w|reverse
# Factor?:                      u[w] != []
# Proper factor?:               u != w and u[w] != []
# Proper factor?:               (u|length) != (w|length) and u[w] != []
# Prefix?:                      w <= u
# Proper prefix?:               w < u
# Suffix?:                      (w|reverse) <= (u|reverse)
# Suffix?:                      ((u|length) - (w|length)) as $n | u[w][-1] == $n
# Proper Suffix?:               (w|reverse) < (u|reverse)
# Proper Suffix?:               ((u|length) - (w|length)) as $n | $n != 0 and u[w][-1] == $n

# A*: infinite words over an alphabet
def words: #:: ALPHABET| => *WORD
    def choose: .[];
    def _words:
        [] # either the empty word
        ,  # or add a word and a symbol from the alphabet
        _words as $seq
        | choose as $element
        | $seq|.[length]=$element
    ;
    if length == 0
    then []
    else _words end
;

# Sets of factors, prefixes ans suffixes
#def factors($k):
#def prefixes($k):
#def suffixes($k):
#def factors:
#def prefixes:
#def suffixes:

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
    every(
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

# vim:ai:sw=4:ts=4:et:syntax=jq
