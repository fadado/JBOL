module {
    name: "array/word",
    description: "Combinatorics on Words",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/array/set" as set;

########################################################################
# Combinatorics on Words

# WORD:                         [a]^string
# Word w:                       [...] or "..."
# Empty word:                   [] or ""
# Concatenate:                  w + u
# Length of w:                  w|length
# Alphabet of w:                w|unique    (only arrays)
# Reverse of w:                 w|reverse   (only arrays)

# Number of a's in w
def count($a): #:: WORD|(a) => number
#   . as $w
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
    or ($u|indices($w))[0] == 0 # or $w is at the beggining of $u
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
# Sets of factors, prefixes ans suffixes

#def factors($k):
#def prefixes($k):
#def suffixes($k):

#def factors:
#def prefixes:
#def suffixes:

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
