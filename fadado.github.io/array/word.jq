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

# Alphabet Σ:                   [a,b,c,...] (a set)
# Σ*:                           Σ|set::kstar
# Σ⁺:                           Σ|set::kplus
# Σⁿ:                           w|set::power(n)

# Word w:                       [...] or "..."
# Empty word:                   [] or ""
# Concatenate:                  w + u
# Length of w:                  w|length
# Alphabet of w:                w|unique    (only arrays)
# Reverse of w:                 w|reverse   (only arrays)

# Language L over Σ:            [w,u...]    (a set)

# Number of a's in w
def count($a): #:: WORD|(SYMBOL) => number
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

def _id_:
    if type == "string"
    then ""
    elif type == "array"
    then []
    else null end
;

# Generates wⁿ (one word: w concatenated n times)
#
def power($n): #:: [a]|(number) => [a]
    . as $word
    | select(0 <= $n) # not defined for negative $n
    | reduce range($n) as $_ (_id_; . + $word)
;

# Generates w*: w⁰ ∪ w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
#
def star: #:: [a]| => +[a]
    . as $word
    | _id_|iterate(. + $word)
;

# Generates w⁺: w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
#
def plus: #:: [a]| => +[a]
    . as $word
    | iterate(. + $word)
;

########################################################################
# Languages

def _add: # specialized add for arrays
    reduce .[] as $w ([]; .+$w)
;

def Lconcat($L1; $L2):
    set::product($L1; $L2) | _add
;

def Lpower($n):
    set::power($n) | _add
;

def Lkstar:
    set::kstar | _add
;

def Lkplus:
    set::kplus | _add
;

# vim:ai:sw=4:ts=4:et:syntax=jq
