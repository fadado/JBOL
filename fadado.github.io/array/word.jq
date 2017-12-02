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

# Alphabet Σ:                   [a,b,c,...] (array/set)
# Σ*:                           Σ|set::kstar (array/set)
# Σ⁺:                           Σ|set::kplus (array/set)
# Σⁿ:                           w|set::power(n)
# Word w:                       [...]
# Empty word:                   []
# Word catenation:              w + u
# Length of w:                  w|length
# Alphabet of w:                w|unique
# Reverse of w:                 w|reverse
# Language L over Σ:            [w,u...]

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

# Generates w*: w⁰ ∪ w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
#
def power: #:: [a]| => +[a]
    . as $word
    | []|iterate(. + $word)
;

# Generates w⁺: w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
#
def power1: #:: [a]| => +[a]
    . as $word
    | iterate(. + $word)
;

# Generates wⁿ
#
def power($n): #:: [a]|(number) => +[a]
    . as $word
    | select(0 <= $n) # not defined for negative $n
    | reduce range($n) as $_ ([]; . + $word)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
