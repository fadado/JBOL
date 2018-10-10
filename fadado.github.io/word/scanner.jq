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
#   TEST:       SYMBOL->boolean

########################################################################
# Match one symbol

# Do satisfies the symbol at `.` in `$w` the predicate `t`?
def meets($w; t): #:: POS|(WORD;TEST) => ?POS
    select(0 <= . and . < ($w|length))
    | select($w[.:.+1] | t)
    | .+1
;

# Icon `any`
def any($w; $wset): #:: POS|(WORD;WORD;POS) => ?POS
    meets($w; inside($wset))
;

# Icon `notany`
def notany($w; $wset): #:: POS|(WORD;WORD) => ?POS
    meets($w; false==inside($wset))
;

########################################################################
# upto
########################################################################

# Positions for all symbols in `$w[.:j]` satisfying `t`
def locus($w; t; $j): #:: POS|(WORD;TEST;POS) => *POS
    . as $i
    | select(0 <= $i and $i < $j and $j <= ($w|length))
    | range($i;$j) as $k
    | select($w[$k:$k+1] | t)
    | $k
;

# Positions for all symbols in `$w[.:]` satisfying `t`
def locus($w; t): #:: POS|(WORD;TEST) => *POS
    locus($w; t; $w|length)
;

# Icon `upto`
def upto($w; $wset; $j): #:: POS|(WORD;WORD;POS) => *POS
    locus($w; inside($wset); $j)
;
def upto($w; $wset): #:: POS|(WORD;WORD) => *POS
    locus($w; inside($wset); $w|length)
;

def upto_c($w; $wset; $j): #:: POS|(WORD;WORD;POS) => *POS
    locus($w; false==inside($wset); $j)
;
def upto_c($w; $wset): #:: POS|(WORD;WORD) => *POS
    locus($w; false==inside($wset); $w|length)
;

########################################################################
# many
########################################################################

# Generalized Icon `many`, SNOBOL `SPAN`, C `strspn`, Haskell `span`
def span($w; t; $j): #:: POS|(WORD;TEST;POS) => ?POS
    . as $i
    | select(0 <= $i and $i < $j)
    | last(meets($w; t) | recurse(meets($w; t)))
      // empty
;
def span($w; t): #:: POS|(WORD;TEST) => ?POS
    span($w; t; $w|length)
;

# Icon `many`
def many($w; $wset; $j): #:: POS|(WORD;WORD;POS;POS) => ?POS
    span($w; inside($wset); $j)
;
def many($w; $wset): #:: POS|(WORD;WORD) => ?POS
    span($w; inside($wset); $w|length)
;

# Complementary of `many`
def many_c($w; $wset; $j): #:: POS|(WORD;WORD;POS;POS) => ?POS
    span($w; false==inside($wset); $j)
;
def many_c($w; $wset): #:: POS|(WORD;WORD) => ?POS
    span($w; false==inside($wset); $w|length)
;

########################################################################
# Match/find word(s)
########################################################################

# Matches u at the begining of w? (Icon `match`)
def match($w; $u; $j): #:: POS|(WORD;WORD;POS)=> ?POS
    select(0 <= . and . < $j)
    | ($u|length) as $n
    | select(.+$n <= $j and $w[.:.+$n] == $u)
    | .+$n
;
def match($w; $u): #:: POS|(WORD;WORD)=> ?POS
    match($w; $u; $w|length)
;

# Global search factor (Icon `find`)
def find($w; $u; $j): #:: POS|(WORD;WORD;POS) => *POS
    select(0 <= . and . < $j and $j <= ($w|length))
    | $w[.:$j] | indices($u)[]
;
def find($w; $u): #:: POS|(WORD;WORD) => *POS
    find($w; $u; $w|length)
;

########################################################################
# Tokenize words
########################################################################

# Produce tokens delimited by `$wset` symbols
def tokens($w; $wset; $j): #:: POS|(WORD;WORD;POS) => *WORD
    def r:
        first(upto_c($w; $wset; $j))    # [delimiters]*(?=[^delimiters])
        | . as $i
        | many_c($w; $wset; $j)         # [^delimiters]+
        | $w[$i:.], r
    ;
    r
;
def tokens($w; $wset): #:: POS|(WORD;WORD) => *WORD
    tokens($w; $wset; $w|length)
;

# Produce tokens consisting in `$wset` symbols
def tokens_c($w; $wset; $j): #:: POS|(WORD;WORD;POS) => *WORD
    def r:
        first(upto($w; $wset; $j))  # [^consisting]*(?=[consisting])
        | . as $i
        | many($w; $wset; $j)       # [consisting]+
        | $w[$i:.], r
    ;
    r
;
def tokens_c($w; $wset): #:: POS|(WORD;WORD) => *WORD
    tokens_c($w; $wset; $w|length)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
