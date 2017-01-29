module {
    name: "snobol",
    description: "SNOBOL embeded in jq",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";

import "fadado.github.io/string" as str;
import "fadado.github.io/generator" as gen;

########################################################################
# Patterns implementation
########################################################################

#
# Cursor definition
#

# All filters must start with the `A` or `U` funcions, and replace the
# &ANCHOR keyword.

# Anchored subject
def A($subject): #:: (string) -> CURSOR
{
    $subject,               # string to scan
    slen:($subject|length), # subject length
    offset:0,               # subject start scanning position
    start:null,             # current pattern start scanning position
    position:0              # current cursor position
};
def A: #:: string| -> CURSOR
    A(.)
;

# Unanchored subject
def U($subject): #:: (string) -> <CURSOR>
    ($subject|length) as $slen
    | range(0; $slen+1) as $offset
| {
    $subject,           # string to scan
    $slen,              # subject length
    $offset,            # subject start scanning position
    start:null,         # current pattern start scanning position
    position:$offset    # current cursor position
};
def U: #:: string| -> <CURSOR>
    U(.)
;

#
# Access to cursor state
#

# Returns the cursor position; similar to the @ operator in SNOBOL
def AT: #:: CURSOR| -> number
    .position
;

# Return a string with the whole pattern match (like & in regexes)
def M: #:: CURSOR| -> string
    .subject[.offset:.position]
;

# Return a string with the last (nearer) pattern match
def N: #:: CURSOR| -> string
    .subject[.start:.position]
;

# Return a string with the matches string prefix, like $` in Perl
def P: #:: CURSOR| -> string
    .subject[0:.offset]
;

# Return a string with the matches string prefix, like $' in Perl
def S: #:: CURSOR| -> string
    .subject[.position:]
;

#
# jq specific patterns
#

# Matches the empty string (always matches), like the empty pattern in SNOBOL
def NULL: #:: CURSOR -> CURSOR
    . # ε
;

# Match a literal, necessary to "wrap" all string literals
def L($literal): #:: CURSOR|(string) -> CURSOR
    ($literal|length) as $tlen
    | select(.position+$tlen <= .slen)
    | select(.subject[.position:.position+$tlen] == $literal)
    | .start=.position
    | .position+=$tlen
;

# Group patterns; blend a composite pattern into an atomic pattern
def G(pattern): #:: CURSOR|(CURSOR|->CURSOR) -> CURSOR
    (.position//0) as $p
    | pattern   # any expression using `,` and/or `|` if necessary
    | .start=$p
;

########################################################################
# Main differences beetween SNOBOL and jq
########################################################################

# An importantt and confusing difference beetween SNOBOL and jq are the
# operators for alternation and concatenation:
#
#                   SNOBOL  jq
# ===============================
# alternation       P | Q   P , Q
# concatenation     P Q     P | Q

# To replace the SNOBOL patterns that perform assignments use the following
# equivalences:
#
# SNOBOL           jq
# =============================
# P @V             P | AT as $v
# P $ V            P | N as $v
# P . V            P | N as $v
# (P...Q) . V      P...Q | M as $v
# (P...Q) . V      G(P...Q) | N as $v

# In jq you don't need unevaluated references. For example, replace the
# following SNOBOL statement:
#   FINDW = ' ' *W  ANY(' .,')
# for this jq function:
#   def FINDW(W): L(" ") | W | ANY(" .,")

########################################################################
# Standard SNOBOL
########################################################################

# For documentation see <http://snobol4.org> or <http://snobol4.org>.

#
# Predicates
#

def EQ($m; $n): #:: (number;number) -> CURSOR
    select($m == $n)
;
def NE($m; $n): #:: (number;number) -> CURSOR
    select($m != $n)
;
def GE($m; $n): #:: (number;number) -> CURSOR
    select($m >= $n)
;
def GT($m; $n): #:: (number;number) -> CURSOR
    select($m >  $n)
;
def LE($m; $n): #:: (number;number) -> CURSOR
    select($m >= $n)
;
def LT($m; $n): #:: (number;number) -> CURSOR
    select($m >  $n)
;

def LGT($s; $t): #:: (string;string) -> CURSOR
    select(isstring($s) and $s > $t)
;
def IDENT($s; $t): #:: (string;string) -> CURSOR
    select($s == $t)
;
def IDENT($s): #:: (string;string) -> CURSOR
    select($s == "")
;
def DIFFER($s; $t): #:: (string;string) -> CURSOR
    select($s != $t)
;
def DIFFER($s): #:: (string;string) -> CURSOR
    select($s != "")
;
def INTEGER($a): #:: (α) -> CURSOR
    def test:
       if isnumber and floor==.
       then true
       elif (tonumber?//false) and (contains(".")|not)
       then true
       else false
       end
    ;
    select(test)
;

#
# String functions
#

def DUPL($s; $n): #:: (string;number) -> string
    select($n >= 0)|if $n==0 then "" else $s*$n end
;
def REPLACE($s; $t; $u): #:: (string;string;string) -> string
    $s|str::translate($t; $u)
;
def SIZE($s): #:: (string) -> number
    $s|length
;

#
# Patterns that control the application of other patterns 
#

def ARBNO(pattern): #:: CURSOR|(CURSOR|->CURSOR) -> <CURSOR>
    iterate(pattern)
;

#
# Patterns concerned with positions in the subject
#

def LEN($n): #:: CURSOR|(number) -> CURSOR
    assert($n >= 0; "LEN requires a non negative number as argument")
    | select(.position+$n <= .slen)
    | .start=.position
    | .position+=$n
;

def TAB($n): #:: CURSOR|(number) -> CURSOR
    assert($n >= 0; "TAB requires a non negative number as argument")
    | select($n >= .position)
    | .start=.position
    | .position=$n
;

def RTAB($n): #:: CURSOR|(number) -> CURSOR
    assert($n >= 0; "RTAB requires a non negative number as argument")
    | select(.slen-$n >= .position)
    | .start=.position
    | .position=.slen-$n
;

def POS($n): #:: CURSOR|(number) -> CURSOR
    assert($n >= 0; "POS requires a non negative number as argument")
    | select(.position == $n)
;

def RPOS($n): #:: CURSOR|(number) -> CURSOR
    assert($n >= 0; "RPOS requires a non negative number as argument")
    | select($n == .slen-.position)
;

#
# Patterns whose actions depend on the character structure of the subject 
#

def ANY($s): #:: CURSOR|(string) -> CURSOR
    assert($s != ""; "ANY requires a non empty string as argument")
    | select(.position != .slen)
    | select(.subject[.position:.position+1] | inside($s))
    | .start=.position
    | .position+=1
;

def NOTANY($s): #:: CURSOR|(string) -> CURSOR
    assert($s != ""; "NOTANY requires a non empty string as argument")
    | select(.position != .slen)
    | select(.subject[.position:.position+1] | inside($s) | not)
    | .start=.position
    | .position+=1
;

def BREAK($s): #:: CURSOR|(string) -> CURSOR
    assert($s != ""; "BREAK requires a non empty string as argument")
    | select(.position != .slen)
    | .position as $p
    | TAB(gen::first(.subject|str::upto($s; $p)))
      // .
;

def SPAN($s): #:: CURSOR|(string) -> CURSOR
    assert($s != ""; "SPAN requires a non empty string as argument")
    | select(.position != .slen)
    | select(.subject[.position:.position+1] | inside($s))
    | G(gen::last(loop(ANY($s))))
;

#
# Patterns concerned with specific types of matching
#

def ARB: #:: CURSOR| -> <CURSOR>
    # equivalent to TAB(range(.position; .slen))
    range(.position; .slen) as $n
    | .start=.position
    | .position=$n
;

def BAL: #:: CURSOR| -> <CURSOR>
    def _bal:
        NOTANY("()")
        , (L("(") | iterate(_bal) | L(")"))
    ;
    G(loop(_bal))
;

def REM: #:: CURSOR| -> CURSOR
    # equivalent to RTAB(0)
    .start=.position
    | .position=.slen
;

#
# Patterns concerned with control of the matching process 
#

def ABORT: #:: CURSOR| -> CURSOR
    error("ABORT")
    # With label/break:
    #   label $abort | P | Q , break $abort | R;
;

def FAIL: #:: CURSOR| -> CURSOR
    empty
;

def FENCE: #:: CURSOR| -> CURSOR
    . , error("ABORT")
    # With label/break:
    #   label $abort | P | NULL , break $abort | Q;
;

def SUCCEED: #::CURSOR| -> <CURSOR>
    iterate(.)
;

# By default SNOBOL tries only once to match, but by default jq tries all
# alternatives. To restrict evaluation to one value use the function `first` or
# this construct:
#   label $exit | P | Q | NULL , break $exit;

########################################################################
# Extensions
########################################################################

#
# SPITBOL extensions
#

def BREAKX($s): #:: CURSOR|(string) -> <CURSOR>
    assert($s != ""; "BREAKX requires a non empty string as argument")
    | select(.position != .slen)
    .position as $p
    | TAB(.subject|str::upto($s; $p))
      // .
;

def LEQ($s; $t): #:: (string;string) -> CURSOR
    select(isstring($s) and $s == $t)
;
def LGE($s; $t): #:: (string;string) -> CURSOR
    select(isstring($s) and $s >= $t)
;
def LLE($s; $t): #:: (string;string) -> CURSOR
    select(isstring($s) and $s >= $t)
;
def LLT($s; $t): #:: (string;string) -> CURSOR
    select(isstring($s) and $s >  $t)
;
def LNE($s; $t): #:: (string;string) -> CURSOR
    select(isstring($s) and $s != $t)
;

def CHAR($n): #:: (number) -> string
    str::char($n)
;
def ORD($s): #:: (string) -> number
    str::ord($s)
;
def LPAD($s; $n): #:: (string;number) -> string
    $s|str::left($n; " ")
;
def LPAD($s; $n; $t): #:: (string;number;string) -> string
    $s|str::left($n; $t)
;
def RPAD($s; $n): #:: (string;number) -> string
    $s|str::right($n; " ")
;
def RPAD($s; $n; $t): #:: (string;number;string) -> string
    $s|str::right($n; $t)
;
def REVERSE($s): #:: (string) -> string
    $s|explode|reverse|implode
;
def SUBSTR($s; $n): #:: (string;number) -> string
    $s[$n:]
;
def SUBSTR($s; $n; $m):  #:: (string;number;number) -> string
    $s[$n:$m]
;
def TRIM($s): #:: (string) -> string
    $s|str::strip(" \t\r\n\f")
;

#
# Extensions found in the literature
#

# also called NOT...
def NO(pattern): #::CURSOR|(CURSOR|->CURSOR) -> CURSOR
    select(failure(pattern))
;

# also called IF, NEXT...
def YES(pattern): #::CURSOR|(CURSOR|->CURSOR) -> CURSOR
    select(success(pattern))
;

# retrofitted from Icon
def FIND($s): #::CURSOR|(pattern) -> <CURSOR>
    .position as $p | .slen as $n
    | TAB(.subject | str::find($s; $p; $n))
;

# retrofitted from Icon
def MOVE($n): #:: CURSOR|(number) -> CURSOR
# TODO: not really tested!!!
    .position+=$n
    # ???
    # if .position < .start then .start=.position else . end
;
# TODO: from SNOBOL4+, define ATB, ARTAB...

def REMOVE($s): #:: (string) -> string
    reduce ((./"")[] | select(inside($s)|not)) as $c
        (""; . + $c)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
