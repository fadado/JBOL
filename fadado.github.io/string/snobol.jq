module {
    name: "string/snobol",
    description: "Pattern matching in the SNOBOL style",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";

import "fadado.github.io/string" as str;

########################################################################
# Patterns concerned with control of the matching process 
########################################################################

def NULL: #:: a => a
    .
;

def FAIL: #:: a => @
    empty
;

def SUCCEED: #::a => +a
#   repeat(NULL)
    NULL , SUCCEED
;

def ABORT: #:: a => !
    error("!")
;

def FENCE: #:: a => a!
    NULL , ABORT
;

# select(p): if p then NULL else FAIL end

def NOT(g): #:: a|(a->*b) => ?a
    select(isempty(g))
;

def IF(g): #:: a|(a->*b) => ?a
    select(succeeds(g))
;

def ARBNO(f): #:: a|(a->a) => *a
#   iterate(f)
    def r: . , (f|r);
    r
;

# By default SNOBOL tries only once to match, but by default jq tries all
# alternatives. To restrict evaluation to one value use the function `first` or
# this construct:
#   label $fence | P | Q | (NULL , break $fence)

########################################################################
# Patterns implementation
########################################################################

#
# Cursor definition
#

# All filters must start with the `A` or `U` funcions, and replace the
# &ANCHOR keyword.

# Anchored subject
def A($subject): #:: (string) => CURSOR
    {
        $subject,               # string to scan
        slen:($subject|length), # subject length
        offset:0,               # subject start scanning position
        start:null,             # current pattern start scanning position
        position:0              # current cursor position
    }
;
def A: #:: string => CURSOR
    A(.)
;

# Unanchored subject
def U($subject): #:: (string) => *CURSOR
    ($subject|length) as $slen
    | range(0; $slen+1) as $offset
    | {
        $subject,           # string to scan
        $slen,              # subject length
        $offset,            # subject start scanning position
        start:null,         # current pattern start scanning position
        position:$offset    # current cursor position
    }
;
def U: #:: string => *CURSOR
    U(.)
;

#
# Access to cursor state
#

# Returns the cursor position; similar to the @ operator in SNOBOL
def AT: #:: CURSOR => number
    .position
;

# Return a string with the whole pattern match (like & in regexes)
def M: #:: CURSOR => string
    .subject[.offset:.position]
;

# Return a string with the last (nearest) pattern match
def N: #:: CURSOR => string
    .subject[.start:.position]
;

# Return a string with the matches string prefix, like $` in Perl
def P: #:: CURSOR => string
    .subject[0:.offset]
;

# Return a string with the matches string suffix, like $' in Perl
def S: #:: CURSOR => string
    .subject[.position:]
;

#
# jq specific patterns
#

# Match a literal, necessary to "wrap" all string literals
def L($literal): #:: CURSOR|(string) => CURSOR
    ($literal|length) as $tlen
    | select(.position+$tlen <= .slen)
    | select(.subject[.position:.position+$tlen] == $literal)
    | .start = .position
    | .position += $tlen
;

# Group patterns; blend a composite pattern into an atomic pattern
def G(pattern): #:: CURSOR|(CURSOR->CURSOR) => CURSOR
    .position as $p | pattern | .start = $p
;

########################################################################
# Main differences beetween SNOBOL and jq
########################################################################

# An important and confusing difference beetween SNOBOL and jq are the
# operators for alternation and concatenation:
#
#                   SNOBOL  jq
# ====================================
# alternation       P | Q   P , Q
# concatenation     P Q     P | Q

# To replace the SNOBOL patterns that perform assignments use the following
# equivalences:
#
# SNOBOL            jq
# ====================================
# P @V              P | AT as $v
# P $ V             P | N as $v
# P . V             P | N as $v
# (P...Q) . V       P...Q | M as $v
# (P...Q) . V       G(P...Q) | N as $v

# In jq you don't need unevaluated references. For example, replace the
# following SNOBOL statement:
#   FINDW = ' ' *W  ANY(' .,')
# for this jq function:
#   def FINDW(W): L(" ") | W | ANY(" .,")

########################################################################
# Standard SNOBOL
########################################################################

# For documentation see <http://snobol4.org> or <http://snobol4.com>.

#
# Predicates
#

def EQ($m; $n): #:: CURSOR|(number;number) => CURSOR
    select($m == $n)
;
def NE($m; $n): #:: CURSOR|(number;number) => CURSOR
    select($m != $n)
;
def GE($m; $n): #:: CURSOR|(number;number) => CURSOR
    select($m >= $n)
;
def GT($m; $n): #:: CURSOR|(number;number) => CURSOR
    select($m >  $n)
;
def LE($m; $n): #:: CURSOR|(number;number) => CURSOR
    select($m >= $n)
;
def LT($m; $n): #:: CURSOR|(number;number) => CURSOR
    select($m >  $n)
;

def LGT($s; $t): #:: CURSOR|(string;string) => CURSOR
    select(isstring($s) and $s > $t)
;
def IDENT($s; $t): #:: CURSOR|(string;string) => CURSOR
    select($s == $t)
;
def IDENT($s): #:: CURSOR|(string;string) => CURSOR
    select($s == "")
;
def DIFFER($s; $t): #:: CURSOR|(string;string) => CURSOR
    select($s != $t)
;
def DIFFER($s): #:: CURSOR|(string;string) => CURSOR
    select($s != "")
;
def INTEGER($a): #:: CURSOR|(a) => CURSOR
    def _integer:
        (isnumber and . == trunc)
        or (tonumber? // false) and (contains(".")|not)
    ;
    select($a|_integer)
;

#
# String functions (not patterns)
#

def DUPL($s; $n): #:: (string;number) => string
    select($n >= 0)
    | $s*$n // ""
;
def REPLACE($s; $t; $u): #:: (string;string;string) => string
    $s|str::translate($t; $u)
;
def SIZE($s): #:: (string) => number
    $s|length
;

#
# Patterns concerned with positions in the subject
#

def LEN($n): #:: CURSOR|(number) => CURSOR
    assert($n >= 0; "LEN requires a non negative number as argument")
    | select(.position+$n <= .slen)
    | .start = .position
    | .position += $n
;

def TAB($p): #:: CURSOR|(number) => CURSOR
    assert($p >= 0; "TAB requires a non negative number as argument")
    | select($p >= .position and $p <= .slen)
    | .start = .position
    | .position = $p
;

def RTAB($r): #:: CURSOR|(number) => CURSOR
    assert($r >= 0; "RTAB requires a non negative number as argument")
    | select(.slen-$r >= .position)
    | .start = .position
    | .position = .slen-$r
;

def POS($p): #:: CURSOR|(number) => CURSOR
    assert($p >= 0; "POS requires a non negative number as argument")
    | select(.position == $p)
;

def RPOS($r): #:: CURSOR|(number) => CURSOR
    assert($r >= 0; "RPOS requires a non negative number as argument")
    | select(.slen-.position == $r)
;

#
# Patterns whose actions depend on the character structure of the subject 
#

def ANY($s): #:: CURSOR|(string) => CURSOR
    assert($s!=""; "ANY requires a non empty string as argument")
    | select(.position != .slen)
    | select(.subject[.position:.position+1] | inside($s))
    | .start = .position
    | .position += 1
;

def NOTANY($s): #:: CURSOR|(string) => CURSOR
    assert($s!=""; "NOTANY requires a non empty string as argument")
    | select(.position != .slen)
    | select(.subject[.position:.position+1] | inside($s) | not)
    | .start = .position
    | .position += 1
;

def SPAN($s): #:: CURSOR|(string) => CURSOR
    assert($s!=""; "SPAN requires a non empty string as argument")
    | select(.position != .slen)
    | G(last(ANY($s)|ARBNO(ANY($s))) // FAIL)  # fail if last == null
;

def BREAK($s): #:: CURSOR|(string) => CURSOR
    assert($s!=""; "BREAK requires a non empty string as argument")
    | select(.position != .slen)
    | G(last(ARBNO(NOTANY($s))))
    | when(.position == .slen; FAIL)
;

#
# Patterns concerned with specific types of matching
#

def ARB: #:: CURSOR => *CURSOR
    # equivalent to TAB(range(.position; .slen))
    .start = .position
    | .position = range(.position; .slen)
;

def BAL: #:: CURSOR => *CURSOR
    def _bal:
        NOTANY("()")
        , (L("(") | ARBNO(_bal) | L(")"))
    ;
    G(_bal | ARBNO(_bal))
;

def REM: #:: CURSOR => CURSOR
    # equivalent to RTAB(0)
    .start = .position
    | .position = .slen
;

########################################################################
# Extensions
########################################################################

#
# SPITBOL extensions
#

def BREAKX($s): #:: CURSOR|(string) => *CURSOR
    def _breakx:
        G(last(ARBNO(NOTANY($s))))
        | when(.position == .slen; FAIL)
        | . , (.position += 1 | _breakx)
    ;
    assert($s!=""; "BREAKX requires a non empty string as argument")
    | select(.position != .slen)
    | _breakx
;

def LEQ($s; $t): #:: CURSOR|(string;string) => CURSOR
    select(isstring($s) and $s == $t)
;
def LGE($s; $t): #:: CURSOR|(string;string) => CURSOR
    select(isstring($s) and $s >= $t)
;
def LLE($s; $t): #:: CURSOR|(string;string) => CURSOR
    select(isstring($s) and $s >= $t)
;
def LLT($s; $t): #:: CURSOR|(string;string) => CURSOR
    select(isstring($s) and $s >  $t)
;
def LNE($s; $t): #:: CURSOR|(string;string) => CURSOR
    select(isstring($s) and $s != $t)
;

def CHAR($n): #:: (number) => string
    str::char($n)
;
def ORD($s): #:: (string) => number
    str::ord($s)
;
def LPAD($s; $n): #:: (string;number) => string
    $s|str::left($n; " ")
;
def LPAD($s; $n; $t): #:: (string;number;string) => string
    $s|str::left($n; $t)
;
def RPAD($s; $n): #:: (string;number) => string
    $s|str::right($n; " ")
;
def RPAD($s; $n; $t): #:: (string;number;string) => string
    $s|str::right($n; $t)
;
def REVERSE($s): #:: (string) => string
    $s|explode|reverse|implode
;
def SUBSTR($s; $n): #:: (string;number) => string
    $s[$n:]
;
def SUBSTR($s; $n; $m):  #:: (string;number;number) => string
    $s[$n:$m]
;
def TRIM($s): #:: (string) => string
    $s|str::strip(" \t\r\n\f")
;

#
# More extensions
#

def BAL($lhs; $rhs): #:: CURSOR|(string;string) => *CURSOR
    def _bal($parens):
        NOTANY($parens)
        , (L($lhs) | ARBNO(_bal) | L($rhs))
    ;
    ($lhs+$rhs) as $s
    | G(_bal($s) | ARBNO(_bal($s)))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
