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
#   TEST:       SYMBOL->boolean
#   POSITION:   number
#   PATTERN:    POSITION->?POSITION
#   SLICE:      [POSITION,POSITION]

########################################################################
# Match one symbol

# Do satisfies the symbol at `.` in `$w` the predicate `t`?
def meets($w; t): #:: POSITION|(WORD;TEST) => ?POSITION
    select(0 <= . and . < ($w|length))
    | select($w[.:.+1] | t)
    | .+1
;

# Icon `any`
def any($w; $alphabet): #:: POSITION|(WORD;WORD) => ?POSITION
    meets($w; inside($alphabet))
;

# Icon `notany`
def notany($w; $alphabet): #:: POSITION|(WORD;WORD) => ?POSITION
    meets($w; false==inside($alphabet))
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
def upto($w; $alphabet): #:: POSITION|(WORD;WORD) => *POSITION
    locus($w; inside($alphabet))
;

def upto_c($w; $alphabet): #:: POSITION|(WORD;WORD) => *POSITION
    locus($w; false==inside($alphabet))
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
def many($w; $alphabet): #:: POSITION|(WORD;WORD) => ?POSITION
    span($w; inside($alphabet))
;

# Complementary of `many`
def many_c($w; $alphabet): #:: POSITION|(WORD;WORD) => ?POSITION
    span($w; false==inside($alphabet))
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
# Balanced tokens
########################################################################

def bal($w; $lhs; $rhs): #:: POSITION|(string;string;string) => *POSITION
    def _bal($braces):
        def gbal:
            notany($w; $braces)
            , (match($w; $lhs) | recurse(gbal) | match($w; $rhs))
        ;
        gbal | recurse(gbal)
    ;
    _bal($lhs+$rhs)
;

########################################################################
# Tokenize words

def tokens($w; begin; token): #:: POSITION|(WORD;PATTERN;PATTERN) => *SLICE
    def r:
        begin
        | . as $i
        | token
        | [$i, .]
          , r
    ;
    r
;

def tokens($w; t): #:: POSITION|(WORD;TEST) => *SLICE
    tokens($w; first(locus($w;t)); span($w;t))
;

# Produce words consisting in `$alphabet` symbols
def words($w; $alphabet): #:: POSITION|(WORD;WORD) => *WORD
#   tokens($w; first(upto($w;$alphabet)); many($w;$alphabet)) as [$i,$j]
    tokens($w; inside($alphabet)) as [$i,$j]
    | $w[$i:$j]
;

# Produce words delimited by `$alphabet` symbols
def words_c($w; $alphabet): #:: POSITION|(WORD;WORD) => *WORD
#   tokens($w; first(upto_c($w;$alphabet)); many_c($w;$alphabet)) as [$i,$j]
    tokens($w; false==inside($alphabet)) as [$i,$j]
    | $w[$i:$j]
;

# Extract numbers
def numbers($w): #:: POSITION|(WORD) => *number
    def opt(p): first(p , .);
    def sign:   opt(any($w;"+-"));
    def start:  first(upto($w;"+-0123456789"));
    def digits: many($w;"0123456789");
#1
    def number: sign | digits | opt((match($w;".") | opt(digits)));
#2  def number: sign | first((digits | match($w;".") | opt(digits)) , digits);
#3  def integer: digits;
#3  def real: digits | match($w;".") | opt(digits);
#3  def number: sign | first(real , integer);

    tokens($w; start; number) as [$i,$j]
    | $w[$i:$j]
    | tonumber
;

# vim:ai:sw=4:ts=4:et:syntax=jq
