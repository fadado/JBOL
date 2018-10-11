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
include "fadado.github.io/types";

########################################################################
# Types used in declarations:
#   WORD:       [a]^string
#   SYMBOL:     singleton WORD

########################################################################
# Generic operations on strings and arrays

# Word w:                       [...] or "..."
# Empty word:                   [] or ""
# Concatenate:                  w + u
# Length of w:                  w|length

# Rotate in both directions
def rotate($n): #:: WORD|(number) => WORD
    .[$n:] + .[:$n]
;
def rotate: #:: WORD => WORD
    .[1:] + .[:1]
;

# Generic reverse
def mirror: #:: WORD => WORD
    if isstring
    then explode | [.[length-1-range(0;length)]] | implode
    elif isarray
    then [.[length-1-range(0;length)]]
    else typerror
    end
;

# Generic alphabet
def alphabet: #:: WORD => WORD
    if isstring
    then explode | unique | implode
    elif isarray
    then unique
    else typerror
    end
;

# Number of u's in w
def count($u): #:: WORD|(WORD) => number
    indices($u) | length
;

########################################################################
# Match one word

# Prefix?
def isprefix($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | $j <= length and .[0:$j] == $u
;

# Suffix?
def issuffix($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | $j == 0 or $j <= length and .[-$j:] == $u
;

# Factor?
def isfactor($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | 0 < $j and index($u)!=null
;

# Proper prefix?
def ispprefix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and isprefix($u)
;

# Proper suffix?
def ispsuffix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and issuffix($u)
;

# Proper factor?
def ispfactor($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | 0 < $j and $j < length and index($u)!=null
;

########################################################################
# Word streams

# Sets of prefixes (without the empty word)
def prefixes: #:: WORD => *WORD
    .[:range(1;length+1)]
;

# Sets of suffixes (without the empty word)
def suffixes: #:: WORD => *WORD
    .[range(length-1;-1;-1):]
;

# Sets of factors, (without the empty word)
def factors: #:: WORD => *WORD
# length order:
    range(1;length+1) as $j
    | range(0;length-$j+1) as $i
    | .[$i:$i+$j]
# different order:
#   range(0;length+1) as $j
#   | range($j+1; length+1) as $i
#   | .[$j:$i]
;

########################################################################
# Word iteration

# Product, catenate: w + u

# Generates wⁿ (one word: w concatenated n times)
def power($n): #:: WORD|(number) => WORD
# assert $n >= 0
    if isstring then
        if $n == 0 or length == 0
        then ""
        else . * $n end
    elif isarray then
        if $n == 0 or length == 0
        then []
        else
            . as $word
            | reduce range(0;$n) as $_
                ([]; . + $word)
        end
    else typerror
    end
;

# Generates w*: w⁰ ∪ w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
def star: #:: WORD => +WORD
    . as $word
    | if isstring then "" else [] end
    | recurse(. + $word)
;

# Generates w⁺: w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
def plus: #:: WORD => +WORD
    . as $word
    | recurse(. + $word)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
