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

# Number of u's in w
def count($u): #:: WORD|(WORD) => number
    indices($u) | length
;

########################################################################
# Find symbol(s)

def symbol(t): #:: WORD|(SYMBOL->boolean) => ?number
    select(length > 0)
    | (if type == "string" then .[0:1] else .[0] end) as $symbol
    | select($symbol|t)
    | 1
;

def gsymbol(t): #:: WORD|(SYMBOL->boolean) => *number
    select(length > 0)
    | (if type == "string" then (./"") else . end) as $symbols
    | range(length)
    | select($symbols[.]|t)
;
def gsymbol(t; $i): #:: WORD|(SYMBOL->boolean;number) => *number
    select(0 <= $i)
    | .[$i:]
    | gsymbol(t)+$i
;
def gsymbol(t; $i; $j): #:: WORD|(SYMBOL->boolean;number;number) => *number
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]
    | gsymbol(t)+$i
;

def upto($u): #:: WORD|(WORD) => *number
    gsymbol(inside($u))
;
def upto($u; $i): #:: WORD|(WORD;number) => *number
    gsymbol(inside($u); $i)
;
def upto($u; $i; $j): #:: WORD|(WORD;number;number) => *number
    gsymbol(inside($u); $i; $j)
;

########################################################################
# Find word

def gfactor($u; $i; $j): #:: WORD|(WORD;number;number) => *number
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]|indices($u)[]
;
def gfactor($u; $i): #:: WORD|(WORD;number) => *number
    select(0 <= $i)
    | .[$i:]|indices($u)[]
;
def gfactor($u): #:: WORD|(WORD) => *number
    indices($u)[]
;

# Factor?
def factor($u): #:: WORD|(WORD) => boolean
    ($u|length) as $n
    | select(0 == $n or $n <= length and .[:$n] == $u)
    | $n
;

# Proper factor?
def pfactor($u): #:: WORD|(WORD) => boolean
    ($u|length) as $n
    | 0 < $n and $n < length and contains($u)
;

# Prefix?
def prefix($u): #:: WORD|(WORD) => boolean
    ($u|length) as $n
    | $n == 0 or .[0:$n] == $u
;

# Proper prefix?
def pprefix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and prefix($u)
;

# Suffix?
def suffix($u): #:: WORD|(WORD) => boolean
    ($u|length) as $n
    | $n == 0 or .[-$n:] == $u
;

# Proper suffix?
def psuffix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and suffix($u)
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
