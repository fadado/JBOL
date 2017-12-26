module {
    name: "word",
    description: "Generic operations on strings and arrays",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

########################################################################
# Generic operations on strings and arrays

# WORD:                         array^string

# Word w:                       [...] or "..."
# Empty word:                   [] or ""
# Concatenate:                  w + u
# Length of w:                  w|length
# Alphabet of w (arrays):       w|unique
# Alphabet of w (strings):      (w/"")|unique
# Reverse of w (only arrays):   w|reverse

# Rotate in both directions
def rotate($n): #:: WORD|(number) => WORD
    .[$n:] + .[:$n]
;
def rotate: #:: WORD => WORD
    .[1:] + .[:1]
;

########################################################################
# Icon style operations 
# See http://www.cs.arizona.edu/icon/refernce/funclist.htm

# Find word
def find($u; $i; $j): #:: WORD|(WORD;number;number) => *number
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]|indices($u)[]
;
def find($u; $i): #:: WORD|(WORD;number) => *number
    select(0 <= $i)
    | .[$i:]|indices($u)[]
;
def find($u): #:: WORD|(WORD) => *number
    find($u; 0; length)
;

# Find symbols
def upto($u): #:: WORD|(WORD) => *number
    def symbols:
        if type == "array"
        then $u[] | [.]
        else ($u/"")[]  # string
        end
    ;
    assert($u|length>0; "upto requires a non empty word as argument")
    | [indices(symbols)[]]
    | unique[]
;
def upto($u; $i; $j): #:: WORD|(WORD;number;number) => *number
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j] | upto($u)+$i
;
def upto($u; $i): #:: WORD|(WORD;number) => *number
    select(0 <= $i)
    | .[$i:] | upto($u)+$i
;

########################################################################
# Combinatorics on Words

# Number of a's in w
def count($a): #:: WORD|(a) => number
    indices($a) | length  # number of occurrences of $a inside $w
;

# Factor?
def factor($u): #:: WORD|(WORD) => boolean
    . as $w
    | length == 0   # $w is the empty word and factor of any word
      or ($u|indices($w)) != []  # or is inside $u
;

# Proper factor?
def pfactor($u): #:: WORD|(WORD) => boolean
    . as $w
    | ($u|length) > length      # $u is larger than $w
      and ($u|indices($w)) != []  # and $w is inside $u
;

# Prefix?
def prefix($u): #:: WORD|(WORD) => boolean
    . as $w
    | length == 0               # $w is the empty word and prefix of any word
      or $u[0:$w|length] == $w
#     or ($u|indices($w))[0] == 0 # or $w is at the beggining of $u
;

# Proper prefix?
def pprefix($u): #:: WORD|(WORD) => boolean
    . as $w
    | ($u|length) > length          # $u is larger than $w
      and ($u|indices($w))[0] == 0    # and $w is prefix of $u
;

# Suffix?
def suffix($u): #:: WORD|(WORD) => boolean
    . as $w
    | length == 0     # $w is the empty word and suffix of any word
      or (($u|length) - length) == ($u|indices($w))[-1] # or $w is at $u end
;

# Proper suffix?
def psuffix($u): #:: WORD|(WORD) => boolean
    . as $w
    | (($u|length) - length) as $n
    | $n > 0                          # $u is larger than $w
      and $n == ($u|indices($w))[-1]  # and $w is at $u end
;

########################################################################
# Sets of factors, prefixes ans suffixes (without the empty word)

def prefixes: #:: WORD => *WORD
    range(1;length+1) as $i
    | .[:$i]
;

def suffixes: #:: WORD => *WORD
    range(length-1;-1;-1) as $i
    | .[$i:]
;

def factors: #:: WORD => *WORD
# length order:
    range(1;length+1) as $j
    | range(length-$j+1) as $i
    | .[$i:$i+$j]
# other order:
#   range(length+1) as $j
#   | range($j+1; length+1) as $i
#   | .[$j:$i]
;

########################################################################
# Word iteration

# Generates wⁿ (one word: w concatenated n times)
#
def power($n): #:: WORD|(number) => WORD
    . as $word
    | select(0 <= $n) # not defined for negative $n
    | if type == "string"
    then if $n == 0 then "" else . * $n end
    else reduce range($n) as $_ ([]; . + $word)
    end
;

# Generates w*: w⁰ ∪ w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
#
def star: #:: WORD => +WORD
    . as $word
    | if type == "string" then "" else [] end
    | iterate(. + $word)
;

# Generates w⁺: w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
#
def plus: #:: WORD => +WORD
    . as $word
    | iterate(. + $word)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
