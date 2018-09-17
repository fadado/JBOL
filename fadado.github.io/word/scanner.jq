module {
    name: "word/scanner",
    description: "Icon style scanner operations on words",
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
# Match symbol at position 0/$i

# Do satisfies the first symbol in w the predicate t?
def g_sym(t): #:: WORD|(SYMBOL->boolean) => ?POS
    select(length > 0)
    | select(.[0:1] | t)
    | 1
;

# Do satisfies the symbol at i in w the predicate t?
def g_sym(t; $i): #:: WORD|(SYMBOL->boolean;POS) => ?POS
    select(0 <= $i and $i < length)
    | select(.[$i:$i+1] | t)
    | $i+1
;

# Icon `any`
def any($wset): #:: WORD|(WORD) => ?POS
    g_sym(inside($wset))
;
def any($wset; $i): #:: WORD|(WORD;POS) => ?POS
    g_sym(inside($wset); $i)
;

# Icon `notany`
def notany($wset): #:: WORD|(WORD) => ?POS
    g_sym(false==inside($wset))
;
def notany($wset; $i): #:: WORD|(WORD;POS) => ?POS
    g_sym(false==inside($wset); $i)
;

########################################################################
# upto
########################################################################

# Positions for all symbols in w satisfying t
def g_upto(t): #:: WORD|(SYMBOL->boolean) => *POS
    select(length > 0)
    | range(0;length) as $j
    | select(.[$j:$j+1] | t)
    | $j
;

# Positions for all symbols in w[i:] satisfying t
def g_upto(t; $i): #:: WORD|(SYMBOL->boolean;POS) => *POS
    select(0 <= $i and $i < length)
    | .[$i:]
    | g_upto(t)+$i
;

# Positions for all symbols in w[i:j] satisfying t
def g_upto(t; $i; $j): #:: WORD|(SYMBOL->boolean;POS;POS) => *POS
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]
    | g_upto(t)+$i
;

# Icon `upto`
def upto($wset): #:: WORD|(WORD) => *POS
    g_upto(inside($wset))
;
def upto($wset; $i): #:: WORD|(WORD;POS) => *POS
    g_upto(inside($wset); $i)
;
def upto($wset; $i; $j): #:: WORD|(WORD;POS;POS) => *POS
    g_upto(inside($wset); $i; $j)
;

def upto_c($wset): #:: WORD|(WORD) => *POS
    g_upto(false==inside($wset))
;
def upto_c($wset; $i): #:: WORD|(WORD;POS) => *POS
    g_upto(false==inside($wset); $i)
;
def upto_c($wset; $i; $j): #:: WORD|(WORD;POS;POS) => *POS
    g_upto(false==inside($wset); $i; $j)
;

########################################################################
# many
########################################################################

# Generalized Icon `many`
def g_many(t; $i): #:: WORD|(SYMBOL->boolean;POS) => ?POS
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
def g_many(t): #:: WORD|(SYMBOL->boolean) => ?POS
    g_many(t; 0)
;

# Icon `many`
def many($wset; $i): #:: WORD|(WORD;POS) => ?POS
    g_many(inside($wset); $i)
;
def many($wset): #:: WORD|(WORD) => ?POS
    g_many(inside($wset); 0)
;

# Complementary of `many`
def many_c($wset; $i): #:: WORD|(WORD;POS) => ?POS
    g_many(false==inside($wset); $i)
;
def many_c($wset): #:: WORD|(WORD) => ?POS
    g_many(false==inside($wset); 0)
;

########################################################################
# axe
########################################################################

# Generalized SNOBOL BREAK
def g_axe(t; $i): #:: WORD|(SYMBOL->boolean;POS) => ?POS
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
def g_axe(t): #:: WORD|(SYMBOL->boolean) => ?POS
    g_axe(t; 0)
;

# SNOBOL `BREAK`
def axe($wset; $i): #:: WORD|(WORD;POS) => ?POS
    g_axe(inside($wset); $i)
;
def axe($wset): #:: WORD|(WORD) => ?POS
    g_axe(inside($wset); 0)
;

# `axe` complementary
def axe_c($wset; $i): #:: WORD|(WORD;POS) => ?POS
    g_axe(false==inside($wset); $i)
;
def axe_c($wset): #:: WORD|(WORD) => ?POS
    g_axe(false==inside($wset); 0)
;

########################################################################
# Match/find word(s)
########################################################################

# Matches u at the begining of w? (Icon `match`)
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

# vim:ai:sw=4:ts=4:et:syntax=jq
