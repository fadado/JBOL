module {
    name: "word",
    description: "Generic operations on strings and arrays",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

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
