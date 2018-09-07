module {
    name: "string",
    description: "Common string operations, some in the Icon language style",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/object/set" as object;
import "fadado.github.io/string/ascii" as ascii;

########################################################################
# Conversions code <=> character

def ord($s): #:: (string) => number
    $s[0:1] | explode[0]
;

def char($n): #:: (number) => string
    [$n] | implode
;

########################################################################
# Pad strings

def left($n; $t): #:: string|(number;string) => string
    when($n > length;
        ($t*($n-length)) + .)
;
def left($n): #:: string|(number) => string
    left($n; " ")
;

def right($n; $t): #:: string|(number;string) => string
    when($n > length;
         . + ($t*($n-length)))
;
def right($n): #:: string|(number) => string
    right($n; " ")
;

def center($n; $t): #:: string|(number;string) => string
    when($n > length;
        ((($n-length)/2) | trunc) as $i
        | ($t*$i) + . + ($t*$i)
        | when(length != $n; .+$t)
    )
;
def center($n): #:: string|(number) => string
    center($n; " ")
;

########################################################################
# Translation tables

# Translate/remove tables
def table($from; $to): #:: (string;string) => {string}
   ($from/"") as $s
   | ($to/"") as $t
   | reduce range($s|length) as $i
        ({}; . += {($s[$i]):($t[$i]//"")})
;

# Translation table for rotate by 13 places
def rot13: #:: {string}
    def rotate: .[13:] + .[:13];
    table(ascii::ALPHA;
        (ascii::upper|rotate)
            + (ascii::lower|rotate))
;

# Preserve tables
def ptable($from; $preserve): #:: (string;string) => {string}
   object::set($preserve) as $t
   | reduce (($from/"") | unique)[] as $c
        ({}; . += (if $t[$c] then null else {($c):""} end))
;

# Translate characters in input string using translation table
def translate($table): #:: string|({string}) => string
    [ (./"")[] | $table[.]//. ]
    | join("")
;

def translate($from; $to): #:: string|(string;string) => string
    translate(table($from; $to))
;

# tolower:  s|translate(ascii::ttlower)
# toupper:  s|translate(latin1::ttupper)
# rot13:    s|translate(rot13)
# toggle:   s|translate(table(ascii::ALPHA; ascii::alpha))
# remove:   s|translate("to delete"; "")
# preserve: s|translate(s|translate("to preserve"; "")); "")
# preserve: s|translate(ptable(s; "to preserve"))

# TODO: compare with translate version
def remove($s): #:: string|(string) => string
    reduce ((./"")[] | reject(inside($s))) as $c
        (""; . + $c)
;

########################################################################
# Classical trim and strip

def _lndx(predicate): # left index or empty if not found
    label $fence
    | range(0;length-1) as $i
    | reject(.[$i:$i+1] | predicate)
    | ($i , break $fence)
;

def _rndx(predicate): # rigth index or empty if not found
    label $fence
    | range(length-1; 0; -1) as $i
    | reject(.[$i:$i+1] | predicate)
    | ($i+1 , break $fence)
;

def lstrip($s): #:: string|(string) => string
    when(length != 0 and (.[0:1] | inside($s));
        (_lndx(inside($s))//-1) as $i |
        if $i < 0 then "" else .[$i:] end
    )
;

def rstrip($s): #:: string|(string) => string
    when(length != 0 and (.[-1:length] | inside($s));
        (_rndx(inside($s))//-1) as $i |
        if $i < 0 then "" else .[0:$i] end
    )
;

def strip($s): #:: string|(string) => string
    when(length != 0 and ((.[0:1] | inside($s)) or (.[-1:length] | inside($s)));
        (_lndx(inside($s))//-1) as $i |
        (_rndx(inside($s))//-1) as $j |
        if $i < 0 and $j < 0 then ""
        elif $j < 0          then .[$i:]
        elif $i < 0          then .[:$j]
                             else .[$i:$j]
        end
    )
;

def trim: #:: string| => string
    strip(" \t\r\n\f")
;
def ltrim: #:: string| => string
    lstrip(" \t\r\n\f")
;
def rtrim: #:: string| => string
    rstrip(" \t\r\n\f")
;

########################################################################

# Fast add, only for string arrays
def concat: #:: [string] => string
    reduce .[] as $s (""; . + $s)
;

# Fast join, only for string arrays
def join($separator): #:: [string]|(string) => string
    def sep:
        if . == null
        then ""
        else .+$separator
        end
    ;
    reduce .[] as $s (null; sep + $s)
        // ""
;

# vim:ai:sw=4:ts=4:et:syntax=jq
