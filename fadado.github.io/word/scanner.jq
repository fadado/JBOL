module {
    name: "word/scanner",
    description: "Icon scanner operations on words",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

########################################################################
# Types used in declarations:
#   WORD:       [a]^string
#   SYMBOL:     singleton WORD

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
def any($s): #:: WORD|(WORD) => ?number
    symbol(inside($s))
;
def any($s; $i): #:: WORD|(WORD;number) => ?number
    symbol(inside($s); $i)
;

# Icon `notany`
def notany($s): #:: WORD|(WORD) => ?number
    symbol(false==inside($s))
;
def notany($s; $i): #:: WORD|(WORD;number) => ?number
    symbol(false==inside($s); $i)
;

########################################################################

# Positions for all symbols in w satisfying t
def gsymbol(t): #:: WORD|(SYMBOL->boolean) => *number
    select(length > 0)
    | range(0;length) as $j
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
# Find word(s)

# Matches u at the beggining of w?
def match($u): #:: WORD|(WORD) => ?number
    ($u|length) as $j
    | select($j <= length and .[0:$j] == $u)
    | $j
;
def match($u; $i): #:: WORD|(WORD;number) => ?number
    select(0 <= $i and $i < length)
    | ($u|length) as $j
    | select($i+$j <= length and .[$i:$i+$j] == $u)
    | $i+$j
;

########################################################################

# Global search factor (Icon `find`)
def find($u): #:: WORD|(WORD) => *number
    indices($u)[]
;
def find($u; $i): #:: WORD|(WORD;number) => *number
    select(0 <= $i)
    | .[$i:]
    | indices($u)[]
;
def find($u; $i; $j): #:: WORD|(WORD;number;number) => *number
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]
    | indices($u)[]
;

########################################################################
# Generalized Icon `many` or SNOBOL SPAN

def span(t; $i): #:: WORD|(SYMBOL->boolean;number) => ?number
    select(0 <= $i and $i < length)
    | label $pipe
    | range($i; length+1) as $j
    | if $j == length
      then $j , break$pipe  # fence
      elif .[$j:$j+1] | t
      then empty            # next
      elif $j != $i
      then $j , break$pipe  # fence
      else break$pipe       # abort
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
    span(false==inside($s); $i)
;
def none($s): #:: WORD|(WORD) => ?number
    span(false==inside($s); 0)
;

########################################################################
# Generalized SNOBOL BREAK

def skip(t; $i): #:: WORD|(SYMBOL->boolean;number) => ?number
    select(0 <= $i and $i < length)
    | label $pipe
    | range($i; length+1) as $j
    | if $j == length
      then break$pipe       # abort
      elif .[$j:$j+1] | t
      then $j , break$pipe
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

# vim:ai:sw=4:ts=4:et:syntax=jq
