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
import "fadado.github.io/generator" as stream;

########################################################################
# Patterns implementation
########################################################################

#
# Cursor definition
#

# All filters must start with the `A` or `U` funcions, and replace the
# &ANCHOR keyword.

# Anchored subject
def A($subject): #:: (string)| -> CURSOR
    { $subject,                 # string to scan
      slen:($subject|length),   # subject length
      offset:0,                 # subject start scanning position
      position:0,               # current cursor position
      start:null }              # current pattern start scanning position
;
def A: A(.);

# Unanchored subject
def U($subject): #:: (string)| -> <CURSOR>
    ($subject|length) as $slen
    | range(0; $slen+1) as $offset
    | { $subject,               # string to scan
        $slen,                  # subject length
        $offset,                # subject start scanning position
        position:$offset,       # current cursor position
        start:null }            # current pattern start scanning position
;
def U: U(.);

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
    .
;

# Match a literal, necessary to "wrap" all string literals
def L($t): #:: CURSOR|(string) -> CURSOR
    ($t|length) as $slen
    | select(.position+($t|length) <= .slen)
    | select(.subject[.position:.position+$slen] == $t)
    | .start=.position
    | .position+=$slen
;

# Group patterns; blend a composite pattern into an atomic pattern
def G(pattern): #:: CURSOR|(CURSOR|->CURSOR) -> CURSOR
    .position as $p
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

def EQ($a; $b):     select($a==$b);
def NE($a; $b):     select($a!=$b);
def GE($a; $b):     select($a>=$b);
def GT($a; $b):     select($a>$b);
def LE($a; $b):     select($a>=$b);
def LT($a; $b):     select($a>$b);

def LGT($a; $b):    select(isstring($a) and $a>$b);
def IDENT($a; $b):  select($a==$b);
def IDENT($a):      select($a=="");
def DIFFER($a; $b): select($a!=$b);
def DIFFER($a):     select($a!="");
def INTEGER($x):
    select((($x|isnumber) and ($x|length)==$x)
        or (tonumber//false and ("."|inside($x)|not))
    )
;

#
# String functions
#

def DUPL($s; $n):           select($n >= 0)|if $n==0 then "" else $s*$n end;
def REPLACE($s; $f; $t):    $s|str::translate($f; $t);
def SIZE($s):               $s|length;

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
    | select(.subject[.position:.position+1] | inside($s) | not)
    | G(stream::last(iterate(NOTANY($s))))
#   | . as $cursor
#   | label $found
#   | range(.position; .slen) as $i
#   | if .subject[$i:$i+1] | inside($s) 
#     then empty
#     elif $i==.position
#     then .
#     else (.start=.position|.position=$i+1 , break $found)
#     end
;

def SPAN($s): #:: CURSOR|(string) -> CURSOR
    assert($s != ""; "SPAN requires a non empty string as argument")
    | select(.position != .slen)
    | select(.subject[.position:.position+1] | inside($s))
    | G(stream::last(ANY($s)|iterate(ANY($s))))
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
    G(_bal | iterate(_bal))
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
    #   label $ABORT | P | Q , break $ABORT | R;
;

def FAIL: #:: CURSOR| -> CURSOR
    empty
;

def FENCE: # CURSOR| -> CURSOR
    . , error("ABORT")
    # With label/break:
    #   label $FENCE | P | (NULL , break $FENCE) | Q;
;

def SUCCEED: #::CURSOR| -> <CURSOR>
    iterate(.)
;

# By default SNOBOL tries only once to match, but by default jq tries all
# alternatives. To restrict evaluation to one value use the function `first` or
# this construct:
#   label $once | P | Q | NULL , break $once;

########################################################################
# Popular extensions
########################################################################

def BREAKX($s): #:: CURSOR|(string) -> <CURSOR>
    BREAK($s) | iterate(LEN(1)|BREAK($s))
;

def LEQ($a; $b):    select(isstring($a) and $a==$b);
def LGE($a; $b):    select(isstring($a) and $a>=$b);
def LLE($a; $b):    select(isstring($a) and $a>=$b);
def LLT($a; $b):    select(isstring($a) and $a>$b);
def LNE($a; $b):    select(isstring($a) and $a!=$b);

def CHAR($n):           str::chr($n);
def LPAD($s; $n):       str::lpad($s; $n; " ");
def LPAD($s; $n; $t):   str::lpad($s; $n; $t);
def ORD($n):            str::ord($n);
def REVERSE($s):        str::reverse($s);
def RPAD($s; $n):       str::rpad($s; $n; " ");
def RPAD($s; $n; $t):   str::rpad($s; $n; $t);
def SUBSTR($s; $i):     $s[$i:];
def SUBSTR($s; $i; $j): $s[$i:$j];
def TRIM($s):           $s|str::strip(" \t\r\n\f");

#
# Extensions presented in the James F. Gimpel book
#

def IF(pattern): #::CURSOR|(CURSOR|->CURSOR) -> CURSOR
    select(success(pattern))
;

def NOT(pattern): #::CURSOR|(CURSOR|->CURSOR) -> CURSOR
    select(failure(pattern))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
