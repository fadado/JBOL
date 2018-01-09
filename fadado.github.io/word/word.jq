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
# Types used in declarations:
#   WORD: [a]^string
#   SYMBOL: singleton WORD

########################################################################
# Generic operations on strings and arrays

# Word w:                       [...] or "..."
# Empty word:                   [] or ""
# Concatenate:                  w + u
# Length of w:                  w|length
# Alphabet of w (arrays):       w|unique
# Alphabet of w (strings):      (w/"")|unique|add
# Reverse of w (arrays):        w|reverse
# Reverse of w (strings):       w|explode|reverse|implode

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

# Generic reverse
def mirror: #:: WORD => WORD
    if type == "string"
    then explode|reverse|implode
    else reverse
    end
;

########################################################################
# Find symbol(s)

# Do satisfies the first symbol in w the predicate t?
def symbol(t): #:: WORD|(SYMBOL->boolean) => ?number
    select(length > 0)
    | select(.[0:1]|t)
    | 1
;

# Do satisfies the symbol at i in w the predicate t?
def symbol(t; $i): #:: WORD|(SYMBOL->boolean;number) => ?number
    select(0 <= $i and $i < length)
    | select(.[$i:$i+1]|t)
    | $i+1
;

# Icon `any`
def anyone($s): #:: WORD|(WORD) => ?number
    symbol(inside($s))
;
def anyone($s; $i): #:: WORD|(WORD;number) => ?number
    symbol(inside($s); $i)
;

# Icon `notany`
def notany($s): #:: WORD|(WORD) => ?number
    symbol(inside($s)|not)
;
def notany($s; $i): #:: WORD|(WORD;number) => ?number
    symbol(inside($s)|not; $i)
;

########################################################################

# Positions for all symbols in w satisfying t
def gsymbol(t): #:: WORD|(SYMBOL->boolean) => *number
    select(length > 0)
    | range(length) as $j
    | select(.[$j:$j+1]|t)
    | $j
;

# Positions for all symbols in w[i:] satisfying t
def gsymbol(t; $i): #:: WORD|(SYMBOL->boolean;number) => *number
    select(0 <= $i and $i < length)
    | .[$i:]
    | gsymbol(t)+$i
;

# Positions for all symbols in w[i:j] satisfying t
def gsymbol(t; $i; $j): #:: WORD|(SYMBOL->boolean;number;number) => *number
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]
    | gsymbol(t)+$i
;

# Icon `upto`
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
# Match one word

# Matches u at the beggining of w?
def factor($u): #:: WORD|(WORD) => ?number
    ($u|length) as $j
    | select($j <= length and .[0:$j] == $u)
    | $j
;
def factor($u; $i): #:: WORD|(WORD;number) => ?number
    select(0 <= $i and $i < length)
    | ($u|length) as $j
    | select($i+$j <= length and .[$i:$i+$j] == $u)
    | $i+$j
;

# Prefix?
def prefix($u): #:: WORD|(WORD) => boolean
    succeeds(factor($u))
;

# Suffix?
def suffix($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | $j == 0 or $j <= length and .[-$j:] == $u
;

# Proper prefix?
def pprefix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and prefix($u)
;

# Proper suffix?
def psuffix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and suffix($u)
;

########################################################################
# Find word in all positions

# Global search factor (Icon `find`)
def gfactor($u): #:: WORD|(WORD) => *number
    indices($u)[]
;
def gfactor($u; $i): #:: WORD|(WORD;number) => *number
    select(0 <= $i)
    | .[$i:]
    | indices($u)[]
;
def gfactor($u; $i; $j): #:: WORD|(WORD;number;number) => *number
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]
    | indices($u)[]
;

# Proper factor?
def pfactor($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | 0 < $j and $j < length and contains($u)
;

########################################################################
# Generalized Icon `many` or SNOBOL SPAN

def span(t; $i): #:: WORD|(SYMBOL->boolean;number) => ?number
    select(0 <= $i and $i < length)
    | label $out
    | range($i; length+1) as $j
    | if $j == length
      then $j , break$out   # fence
      elif .[$j:$j+1] | t
      then empty            # next
      elif $j != $i
      then $j , break$out   # fence
      else break$out        # abort
      end
;
def span(t): #:: WORD|(SYMBOL->boolean) => ?number
    span(t; 0)
;

# Icon `many`
def many($s; $i): #:: WORD|(WORD;number) => ?number
    span(inside($s); $i)
;
def many($s): #:: WORD|(WORD) => ?number
    span(inside($s); 0)
;

# Complementary of `many`
def none($s; $i): #:: WORD|(WORD;number) => ?number
    span(inside($s)|not; $i)
;
def none($s): #:: WORD|(WORD) => ?number
    span(inside($s)|not; 0)
;

########################################################################
# Generalized SNOBOL BREAK

def skip(t; $i): #:: WORD|(SYMBOL->boolean;number) => ?number
    select(0 <= $i and $i < length)
    | label $out
    | range($i; length+1) as $j
    | if $j == length
      then break$out        # abort
      elif .[$j:$j+1] | t
      then $j , break$out
      else empty            # next
      end
;
def skip(t): #:: WORD|(SYMBOL->boolean) => ?number
    skip(t; 0)
;

# Not in Icon but...
def stop($s; $i): #:: WORD|(WORD;number) => ?number
    skip(inside($s); $i)
;
def stop($s): #:: WORD|(WORD) => ?number
    skip(inside($s); 0)
;

########################################################################
# Word sequences

# Sets of prefixes (without the empty word)
def prefixes: #:: WORD => *WORD
    range(1;length+1) as $i
    | .[:$i]
;

# Sets of suffixes (without the empty word)
def suffixes: #:: WORD => *WORD
    range(length-1;-1;-1) as $i
    | .[$i:]
;

# Sets of factors, (without the empty word)
def factors: #:: WORD => *WORD
# length order:
    range(1;length+1) as $j
    | range(length-$j+1) as $i
    | .[$i:$i+$j]
# different order:
#   range(length+1) as $j
#   | range($j+1; length+1) as $i
#   | .[$j:$i]
;

# Fibbonacci strings
# fibstr("a"; "b") => "a","b","ab","bab","abbab"…
def fibstr($w; $u): #:: (WORD;WORD) => +WORD
    [$w,$u]
    | iterate([.[-1], .[-2]+.[-1]])
    | .[-2]
;

########################################################################
# Word iteration

# Product, catenate: w + u

# Generates wⁿ (one word: w concatenated n times)
def power($n): #:: WORD|(number) => WORD
# assert $n >= 0
    . as $word
    | if type == "string"
    then if $n == 0 then "" else . * $n end
    else reduce range($n) as $_ ([]; . + $word)
    end
;

# Generates w*: w⁰ ∪ w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
def star: #:: WORD => +WORD
    . as $word
    | if type == "string" then "" else [] end
    | iterate(. + $word)
;

# Generates w⁺: w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
def plus: #:: WORD => +WORD
    . as $word
    | iterate(. + $word)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
