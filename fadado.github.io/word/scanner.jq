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

def upto_c($w; $wset): #:: POSITION|(WORD;WORD) => *POSITION
    locus($w; false==inside($wset))
;

########################################################################
# many
########################################################################

# Generalized Icon `many`, SNOBOL `SPAN`, C `strspn`, Haskell `span`
def span($w; t): #:: POSITION|(WORD;TEST) => ?POSITION
    select(0 <= . and . < ($w|length))
    | last(meets($w; t) | recurse(meets($w; t)))
      // empty
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

########################################################################
# Tokenize words
########################################################################

# Produce tokens delimited by `$wset` symbols
def tokens($w; $wset): #:: POSITION|(WORD;WORD) => *WORD
    def r:
        first(upto_c($w; $wset))    # [delimiters]*(?=[^delimiters])
        | . as $i
        | many_c($w; $wset)         # [^delimiters]+
        | $w[$i:.], r
    ;
    r
;
# Produce tokens consisting in `$wset` symbols
def tokens_c($w; $wset): #:: POSITION|(WORD;WORD) => *WORD
    def r:
        first(upto($w; $wset))  # [^consisting]*(?=[consisting])
        | . as $i
        | many($w; $wset)       # [consisting]+
        | $w[$i:.], r
    ;
    r
;

# vim:ai:sw=4:ts=4:et:syntax=jq
