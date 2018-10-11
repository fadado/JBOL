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
#   POSITION:   number
#   TEST:       SYMBOL->boolean

########################################################################
# Match one symbol

# Do satisfies the symbol at `.` in `$w` the predicate `t`?
def meets($w; t): #:: POSITION|(WORD;TEST) => ?POSITION
    select(0 <= . and . < ($w|length))
    | select($w[.:.+1] | t)
    | .+1
;

# Icon `any`
def any($w; $wset): #:: POSITION|(WORD;WORD) => ?POSITION
    meets($w; inside($wset))
;

# Icon `notany`
def notany($w; $wset): #:: POSITION|(WORD;WORD) => ?POSITION
    meets($w; false==inside($wset))
;

########################################################################
# upto
########################################################################

# Positions for all symbols in `$w[.:]` satisfying `t`
def locus($w; t): #:: POSITION|(WORD;TEST) => *POSITION
    ($w|length) as $j
    | select(0 <= . and . < $j)
    | range(.;$j) as $k
    | select($w[$k:$k+1] | t)
    | $k
;

# Icon `upto`
def upto($w; $wset): #:: POSITION|(WORD;WORD) => *POSITION
    locus($w; inside($wset))
;
def upto1($w; $wset): #:: POSITION|(WORD;WORD) => *POSITION
    first(locus($w; inside($wset)))
;

def upto_c($w; $wset): #:: POSITION|(WORD;WORD) => *POSITION
    locus($w; false==inside($wset))
;
def upto1_c($w; $wset): #:: POSITION|(WORD;WORD) => *POSITION
    first(locus($w; false==inside($wset)))
;

########################################################################
# many
########################################################################

# Generalized Icon `many`, SNOBOL `SPAN`, C `strspn`, Haskell `span`
def span($w; t): #:: POSITION|(WORD;TEST) => ?POSITION
# Pure declarative:
#   select(0 <= . and . < ($w|length))
#   | last(meets($w; t) | recurse(meets($w; t)))
#     // empty
# Old school:
    . as $i
    | ($w|length) as $j
    | select(0 <= $i and $i < $j)
    | label $pipe
    # for $k=. to $j+1 (off-value used as a flag)
    | range(.; $j+1) as $k
    | if $k == $j           # if past end, all matched
      then $k , break$pipe  # then return $k
      elif $w[$k:$k+1] | t  # if match at $k
      then empty            # then continue loop
      elif $k > $i          # if moved at least one forward
      then $k , break$pipe  # then return $k
      else break$pipe       # abort, none match!
      end
;

# Icon `many`
def many($w; $wset): #:: POSITION|(WORD;WORD) => ?POSITION
    span($w; inside($wset))
;

# Complementary of `many`
def many_c($w; $wset): #:: POSITION|(WORD;WORD) => ?POSITION
    span($w; false==inside($wset))
;

########################################################################
# Match/find word(s)
########################################################################

# Matches u at the begining of w? (Icon `match`)
def match($w; $u): #:: POSITION|(WORD;WORD)=> ?POSITION
    ($w|length) as $j
    | select(0 <= . and . < $j)
    | ($u|length) as $n
    | select(.+$n <= $j and $w[.:.+$n] == $u)
    | .+$n
;

# Global search factor (Icon `find`)
def find($w; $u): #:: POSITION|(WORD;WORD) => *POSITION
    select(0 <= . and . < ($w|length))
    | $w[.:]
    | indices($u)[]
;

# vim:ai:sw=4:ts=4:et:syntax=jq
