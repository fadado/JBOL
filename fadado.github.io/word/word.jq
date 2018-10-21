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
import "fadado.github.io/math" as math;

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

# Generic alphabet
def alphabet: #:: WORD => WORD
    if isstring
    then explode | unique | implode
    elif isarray
    then unique
    else typerror
    end
;

# Merge two words pairwise
def blend($x; $y): #:: (string;string) => string
    if isstring($x) then
        ($x/"") as $x | ($y/"") as $y |
        reduce range(0; math::max($x,$y | length)) as $i
            (""; .+$x[$i]+$y[$i])
    elif isarray then
        reduce range(0; math::max($x,$y | length)) as $i
            ([]; .+$x[$i]+$y[$i])
    else typerror
    end
;

# Number of u's in w
def count($u): #:: WORD|(WORD) => number
    indices($u) | length
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

# Rotate in both directions
def rotate($n): #:: WORD|(number) => WORD
    .[$n:] + .[:$n]
;
def rotate: #:: WORD => WORD
    .[1:] + .[:1]
;

# Splice word: replace or delete slice
def splice($i; $j; $u): #:: WORD|(number;number;WORD^null) => WORD
    if $i > $j or $j > length
    then . # cannot splice
    else .[:$i] + $u + .[$j:]  # with $u == null: delete!
    end
;
def splice($w; $i; $j; $u): #:: (WORD;number;number;WORD) => WORD
    $w|splice($i;$j;$u)
;

# Replace sub-words
def sub($s; $r): #:: WORD|(WORD;WORD) => WORD
    ($s|length) as $n
    | if length == 0 or $n == 0
      then .
      else
        index($s) as $i
        | if $i == null
          then .
          else splice($i; $i+$n; $r) end
      end
;

def gsub($s; $r): #:: WORD|(WORD;WORD) => WORD
    ($s|length) as $n
    | if length == 0 or $n == 0
      then .
      else
        reduce (indices($s)|reverse[]) as $i
            (.; splice($i; $i+$n; $r))
      end
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
