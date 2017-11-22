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

# Alphabet A:                   [a,b,c,...]
# Word w:                       [...]
# A*:                           A | choice::words => *w
# Catenation:                   w + u
# Language L over A:            [w,u...]
# Length of w:                  w|length
# Alphabet of w:                w|unique
# Reverse of a word:            w|reverse

# Number of a's in w
def count($a): #:: WORD|(SYMBOL) => number
#   . as $w
    .[[$a]] | length  # number of occurrences of $a inside $w
;

# Factor?
def factor($u): #:: WORD|(WORD) => boolean
#   . as $w
    length == 0     # $w is the empty word and factor of any word
    or $u[.] != []  # or is inside $u
;

# Proper factor?
def pfactor($u): #:: WORD|(WORD) => boolean
#   . as $w
    ($u|length) > length    # $u is larger than $w
    and $u[.] != []         # and $w is inside $u
;

# Prefix?
def prefix($u): #:: WORD|(WORD) => boolean
#   . as $w
    length == 0         # $w is the empty word and prefix of any word
    or $u[.][0] == 0    # or $w is at the beggining of $u
;

# Proper prefix?
def pprefix($u): #:: WORD|(WORD) => boolean
#   . as $w
    ($u|length) > length    # $u is larger than $w
    and $u[.][0] == 0       # and $w is prefix of $u
;

# Suffix?
def suffix($u): #:: WORD|(WORD) => boolean
#   . as $w
    length == 0     # $w is the empty word and suffix of any word
    or (($u|length) - length) == $u[.][-1] # or $w is at $u end
;

# Proper suffix?
def psuffix($u): #:: WORD|(WORD) => boolean
#   . as $w
    (($u|length) - length) as $n
    | $n > 0                # $u is larger than $w
      and $n == $u[.][-1]   # and $w is at $u end
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
