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
# Match one symbol

# Do satisfies the symbol at `i` in `.` the predicate `t`?
def meets(t; $i): #:: WORD|(SYMBOL->boolean;POS) => ?POS
    select(0 <= $i and $i < length)
    | select(.[$i:$i+1] | t)
    | $i+1
;

# Do satisfies the first symbol in `.` the predicate `t`?
def meets(t): #:: WORD|(SYMBOL->boolean) => ?POS
    select(length > 0)
    | select(.[0:1] | t)
    | 1
;

# Icon `any`
def any($wset; $i): #:: WORD|(WORD;POS) => ?POS
    meets(inside($wset); $i)
;
def any($wset): #:: WORD|(WORD) => ?POS
    meets(inside($wset); 0)
;

# Icon `notany`
def notany($wset; $i): #:: WORD|(WORD;POS) => ?POS
    meets(false==inside($wset); $i)
;
def notany($wset): #:: WORD|(WORD) => ?POS
    meets(false==inside($wset); 0)
;

########################################################################
# upto
########################################################################

# Positions for all symbols in `.[i:j]` satisfying `t`
def locus(t; $i; $j): #:: WORD|(SYMBOL->boolean;POS;POS) => *POS
    select(0 <= $i and $i < $j and $j <= length)
    | range($i;$j) as $k
    | select(.[$k:$k+1] | t)
    | $k
;

# Positions for all symbols in `.[i:]` satisfying `t`
def locus(t; $i): #:: WORD|(SYMBOL->boolean;POS) => *POS
    locus(t; $i; length)
;

# Positions for all symbols in `.` satisfying `t`
def locus(t): #:: WORD|(SYMBOL->boolean) => *POS
    locus(t; 0; length)
;

# Icon `upto`
def upto($wset; $i; $j): #:: WORD|(WORD;POS;POS) => *POS
    locus(inside($wset); $i; $j)
;
def upto($wset; $i): #:: WORD|(WORD;POS) => *POS
    locus(inside($wset); $i; length)
;
def upto($wset): #:: WORD|(WORD) => *POS
    locus(inside($wset); 0; length)
;

def upto_c($wset; $i; $j): #:: WORD|(WORD;POS;POS) => *POS
    locus(false==inside($wset); $i; $j)
;
def upto_c($wset; $i): #:: WORD|(WORD;POS) => *POS
    locus(false==inside($wset); $i; length)
;
def upto_c($wset): #:: WORD|(WORD) => *POS
    locus(false==inside($wset); 0; length)
;

########################################################################
# many
########################################################################

# Generalized Icon `many`, SNOBOL `SPAN`, C `strspn`, Haskell `span`
def span(t; $i; $j): #:: WORD|(SYMBOL->boolean;POS;POS) => ?POS
    select(0 <= $i and $i < $j)
    | label $pipe
    # for $k=$i to $j+1 (off-value used as a flag)
    | range($i; $j+1) as $k
    | if $k == length       # if past end, all matched
      then $k , break$pipe  # then return $k
      elif .[$k:$k+1] | t   # if match at $k
      then empty            # then continue loop
      elif $k > $i          # if moved at least one forward
      then $k , break$pipe  # then return $k
      else break$pipe       # abort, none match!
      end
;
def span(t; $i): #:: WORD|(SYMBOL->boolean;POS) => ?POS
    span(t; $i; length)
;
def span(t): #:: WORD|(SYMBOL->boolean) => ?POS
    span(t; 0; length)
;

# Icon `many`
def many($wset; $i; $j): #:: WORD|(WORD;POS;POS) => ?POS
    span(inside($wset); $i; $j)
;
def many($wset; $i): #:: WORD|(WORD;POS) => ?POS
    span(inside($wset); $i; length)
;
def many($wset): #:: WORD|(WORD) => ?POS
    span(inside($wset); 0; length)
;

# Complementary of `many`
def many_c($wset; $i; $j): #:: WORD|(WORD;POS;POS) => ?POS
    span(false==inside($wset); $i; $j)
;
def many_c($wset; $i): #:: WORD|(WORD;POS) => ?POS
    span(false==inside($wset); $i; length)
;
def many_c($wset): #:: WORD|(WORD) => ?POS
    span(false==inside($wset); 0; length)
;

########################################################################
# Match/find word(s)
########################################################################

# Matches u at the begining of w? (Icon `match`)
def match($u; $i): #:: WORD|(WORD;POS) => ?POS
    select(0 <= $i and $i < length)
    | ($u|length) as $j
    | select($i+$j <= length and .[$i:$i+$j] == $u)
    | $i+$j
;
def match($u): #:: WORD|(WORD) => ?POS
    ($u|length) as $j
    | select($j <= length and .[0:$j] == $u)
    | $j
;

# Global search factor (Icon `find`)
def find($u; $i; $j): #:: WORD|(WORD;POS;POS) => *POS
    select(0 <= $i and $i < $j and $j <= length)
    | .[$i:$j]
    | indices($u)[]
;
def find($u; $i): #:: WORD|(WORD;POS) => *POS
    select(0 <= $i)
    | .[$i:]
    | indices($u)[]
;
def find($u): #:: WORD|(WORD) => *POS
    indices($u)[]
;

########################################################################
# Tokenize words
########################################################################

# Produce tokens delimited by `$wset` symbols
def tokens($wset): #:: WORD|(WORD) => *WORD
    def _tokens_c($str):
        def r:
            . as $i
            | $str # set subject
            | first(upto_c($wset; $i)) as $j # [delimiters]*(?=[^delimiters])
            | many_c($wset; $j) as $k        # [^delimiters]+
            | $str[$j:$k], ($k|r)
        ;
        0 | r
    ;
    _tokens_c(.)
;

# Produce tokens consisting in `$wset` symbols
def tokens_c($wset): #:: WORD|(WORD) => *WORD
    def _words($str):
        def r:
            . as $i
            | $str # set subject
            | first(upto($wset; $i)) as $j # [^consisting]*(?=[consisting])
            | many($wset; $j) as $k        # [consisting]+
            | $str[$j:$k], ($k|r)
        ;
        0 | r
    ;
    _words(.)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
