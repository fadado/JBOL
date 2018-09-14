module {
    name: "word/scanner",
    description: "Icon scanner operations on words",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

########################################################################
# Types used in declarations:
#   WORD:       [a]^string
#   SYMBOL:     singleton WORD
#   POS:        number

########################################################################
# Find symbol(s)

# Do satisfies the first symbol in w the predicate t?
def symbol(t): #:: WORD|(SYMBOL->boolean) => ?POS
    select(length > 0)
    | select(.[0:1]|t)
    | 1
;

# Do satisfies the symbol at i in w the predicate t?
def symbol(t; $i): #:: WORD|(SYMBOL->boolean;POS) => ?POS
    select(0 <= $i and $i < length)
    | select(.[$i:$i+1]|t)
    | $i+1
;

# Icon `any`
def any($s): #:: WORD|(WORD) => ?POS
    symbol(inside($s))
;
def any($s; $i): #:: WORD|(WORD;POS) => ?POS
    symbol(inside($s); $i)
;

# Icon `notany`
def notany($s): #:: WORD|(WORD) => ?POS
    symbol(false==inside($s))
;
def notany($s; $i): #:: WORD|(WORD;POS) => ?POS
    symbol(false==inside($s); $i)
;

########################################################################

# Positions for all symbols in w satisfying t
def gsymbol(t): #:: WORD|(SYMBOL->boolean) => *POS
    select(length > 0)
    | range(0;length) as $j
    | select(.[$j:$j+1]|t)
    | $j
;

# Positions for all symbols in w[i:] satisfying t
def gsymbol(t; $i): #:: WORD|(SYMBOL->boolean;POS) => *POS
    select(0 <= $i and $i < length)
    | .[$i:]
    | gsymbol(t)+$i
;

# Positions for all symbols in w[i:j] satisfying t
def gsymbol(t; $i; $j): #:: WORD|(SYMBOL->boolean;POS;POS) => *POS
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]
    | gsymbol(t)+$i
;

# Icon `upto`
def upto($u): #:: WORD|(WORD) => *POS
    gsymbol(inside($u))
;
def upto($u; $i): #:: WORD|(WORD;POS) => *POS
    gsymbol(inside($u); $i)
;
def upto($u; $i; $j): #:: WORD|(WORD;POS;POS) => *POS
    gsymbol(inside($u); $i; $j)
;

########################################################################
# Find word(s)

# Matches u at the beggining of w? (Icon `match`)
def match($u): #:: WORD|(WORD) => ?POS
    ($u|length) as $j
    | select($j <= length and .[0:$j] == $u)
    | $j
;
def match($u; $i): #:: WORD|(WORD;POS) => ?POS
    select(0 <= $i and $i < length)
    | ($u|length) as $j
    | select($i+$j <= length and .[$i:$i+$j] == $u)
    | $i+$j
;

# Global search factor (Icon `find`)
def find($u): #:: WORD|(WORD) => *POS
    indices($u)[]
;
def find($u; $i): #:: WORD|(WORD;POS) => *POS
    select(0 <= $i)
    | .[$i:]
    | indices($u)[]
;
def find($u; $i; $j): #:: WORD|(WORD;POS;POS) => *POS
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]
    | indices($u)[]
;

########################################################################
# Generalized Icon `many` or SNOBOL SPAN

def span(t; $i): #:: WORD|(SYMBOL->boolean;POS) => ?POS
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
def span(t): #:: WORD|(SYMBOL->boolean) => ?POS
    span(t; 0)
;

# Icon `many`
def many($s; $i): #:: WORD|(WORD;POS) => ?POS
    span(inside($s); $i)
;
def many($s): #:: WORD|(WORD) => ?POS
    span(inside($s); 0)
;

# Complementary of `many`
def none($s; $i): #:: WORD|(WORD;POS) => ?POS
    span(false==inside($s); $i)
;
def none($s): #:: WORD|(WORD) => ?POS
    span(false==inside($s); 0)
;

########################################################################
# Generalized SNOBOL BREAK

def terminate(t; $i): #:: WORD|(SYMBOL->boolean;POS) => ?POS
    select(0 <= $i and $i < length)
    | label $pipe
    | range($i; length+1) as $j
    | if $j == length
      then break$pipe       # abort
      elif .[$j:$j+1] | t
      then $j , break$pipe  # fence
      else empty            # next
      end
;
def terminate(t): #:: WORD|(SYMBOL->boolean) => ?POS
    terminate(t; 0)
;

# SNOBOL `BREAK`
def stop($s; $i): #:: WORD|(WORD;POS) => ?POS
    terminate(inside($s); $i)
;
def stop($s): #:: WORD|(WORD) => ?POS
    terminate(inside($s); 0)
;

def skip($s; $i): #:: WORD|(WORD;POS) => ?POS
    terminate(false==inside($s); $i)
;
def skip($s): #:: WORD|(WORD) => ?POS
    terminate(false==inside($s); 0)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
