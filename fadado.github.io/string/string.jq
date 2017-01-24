module {
    name: "string",
    description: "Common string operations",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";
include "fadado.github.io/math";

import "fadado.github.io/string/ascii" as ascii;

########################################################################
# Icon style text operations 
# See http://www.cs.arizona.edu/icon/refernce/funclist.htm

# Find string
def find($s; $i; $j): #:: string|(string;number;number) -> <number>
    select($i >= 0 and $i < $j and $i < length and $j <= length)
    | indices($s[$i:$j])[]
;
def find($s; $i): #:: string|(string;number) -> <number>
    find($s; $i; length)
;
def find($s): #:: string|(string) -> <number>
    find($s;  0; length)
;

# Locate characters
def upto($s; $i; $j): #:: string|(string;number;number) -> <number>
    assert($s != ""; "upto requires a non empty string as argument")
    | select($i >= 0 and $i < $j and $i < length and $j <= length)
    | range($i; $j) as $p
    | keep ($p; .[$p:$p+1]|inside($s))
;
def upto($s; $i): #:: string|(string;number) -> <number>
    upto($s; $i; length)
;
def upto($s): #:: string|(string) -> <number>
    upto($s;  0; length)
;

# Match initial string
def match($s; $i): #:: string|(string;number) -> number
    select($i >= 0 and $i < length)
    | keep ($i+($s|length); .[$i:]|startswith($s))
;
def match($s): #:: string|(string) -> number
    match($s; 0)
;

# Locate initial character
def any($s; $i): #:: string|(string;number) -> number
    select($i >= 0 and $i < length)
    | keep ($i+1; .[$i:$i+1]|inside($s))
;
def any($s): #:: string|(string) -> number
    any($s; 0)
;

def notany($s; $i): #:: string|(string;number) -> number
    select($i >= 0 and $i < length)
    | keep ($i+1; .[$i:$i+1]|inside($s)|not)
;
def notany($s): #:: string|(string) -> number
    notany($s; 0)
;

# Locate many characters
def many($s; $i): #:: string|(string;number) -> number
    def _many($t; $n):
        def r:
            if .==$n    # all matched
            then $n
            elif $t[.:.+1]|inside($s)
            then .+1|r
            elif .==$i  # none matched
            then empty
            else .
            end
        ;
        $i|r
    ;
    select($i >= 0 and $i < length)
    | _many(.; length)
;
def many($s): #:: string|(string) -> number
    many($s; 0)
;

def none($s; $i): #:: string|(string;number) -> number
    def _none($t; $n):
        def r:
            if .==$n
            then $n
            elif $t[.:.+1]|inside($s)|not
            then .+1|r
            elif .==$i
            then empty
            else .
            end
        ;
        $i|r
    ;
    select($i >= 0 and $i < length)
    | _none(.; length)
;
def none($s): #:: string|(string) -> number
    none($s; 0)
;

# Pad strings
def left($n; $t): #:: string|(number;string) -> string
    when ($n > length; ($t*($n-length)) + .)
;
def left($n): #:: string|(number) -> string
    left($n; " ")
;

def right($n; $t): #:: string|(number;string) -> string
    when ($n > length; . + ($t*($n-length)))
;
def right($n): #:: string|(number) -> string
    right($n; " ")
;

def center($n; $t): #:: string|(number;string) -> string
    when ($n > length;
        ((($n-length)/2)|floor) as $i
        | ($t*$i) + . + ($t*$i)
        | when (length!=$n; .+$t)
    )
;
def center($n): #:: string|(number) -> string
    center($n; " ")
;

def ord($s): #:: (string) -> number
    $s[0:1]|explode[0]
;

def char($n): #:: (number) -> string
    [$n]|implode
;

########################################################################
# Translation tables

# Translate/remove tables
#
def table($from; $to): #:: (string;string) -> TABLE
   ($from/"") as $s
   | ($to/"") as $t
   | reduce range($s|length) as $i
        ({}; . += {($s[$i]):($t[$i]//"")})
;

# Rotate strings in both directions
#
def rotate($s; $n): #:: (string; number) -> string
    $s[$n:] + $s[:$n]
;

def rotate($n): #:: string|(number) -> string
    rotate(.; $n)
;

# Translation table for rotate by 13 places
#
def rot13: #:: TABLE
    table(ascii::ALPHA; rotate(ascii::upper; 13)+rotate(ascii::lower; 13))
;

# Preserve tables
#
def ptable($from; $preserve): #:: (string;string) -> TABLE
   set($preserve) as $t
   | reduce (($from/"")|unique)[] as $c
        ({}; . += (if $t[$c] then null else {($c):""} end))
;

# Translate characters in input string using translation table
#
def translate($table): #:: string|(TABLE) -> string
    [ (./"")[] | $table[.]//. ] | join("")
;

def translate($from; $to): #:: string|(string:string) -> string
    translate(table($from; $to))
;

# tolower:  s|translate(ascii::ttlower)
# toupper:  s|translate(latin1::ttupper)
# rot13:    s|translate(rot13)
# toggle:   s|translate(table(ascii::ALPHA; ascii::alpha))
# remove:   s|translate("to delete"; "")
# preserve: s|translate(s|translate("to preserve"; "")); "")
# preserve: s|translate(ptable(s; "to preserve"))

########################################################################
# Classical trim and strip

def _lndx(predicate): # left index or empty if not found
    label $found
    | range(length-1) as $i
    | if .[$i:$i+1]|predicate
      then empty
      else $i , break $found
      end
;

def _rndx(predicate): # rigth index or empty if not found
    label $found
    | range(length-1; 0; -1) as $i
    | if .[$i:$i+1]|predicate
      then empty
      else $i+1 , break $found
      end
;

def lstrip($s): #:: string|(string) -> string
    if length==0 or (.[0:1]|inside($s)|not)
    then .
    else
        (_lndx(inside($s))//-1) as $i
        | if $i < 0 then "" else .[$i:] end
    end
;

def rstrip($s): #:: string|(string) -> string
    if length==0 or (.[-1:length]|inside($s)|not)
    then .
    else
        (_rndx(inside($s))//-1) as $i
        | if $i < 0 then "" else .[0:$i] end
    end
;

def strip($s): #:: string|(string) -> string
    if length==0 or ((.[0:1]|inside($s)) or (.[-1:length]|inside($s)) | not)
    then .
    else
        (_lndx(inside($s))//-1) as $i |
        (_rndx(inside($s))//-1) as $j |
        if $i < 0 and $j < 0 then ""
        elif $j < 0          then .[$i:]
        elif $i < 0          then .[:$j]
                             else .[$i:$j]
        end
    end
;

def trim: #:: string| -> string
    strip(" \t\r\n\f")
;
def ltrim: #:: string| -> string
    lstrip(" \t\r\n\f")
;
def rtrim: #:: string| -> string
    rstrip(" \t\r\n\f")
;

########################################################################

# Fast join, only for string arrays
#
def join($separator): #:: [string]|(string) -> string
    def sep:
        if .==null
        then ""
        else .+$separator
        end
    ;
    reduce .[] as $s
        (null; sep + $s)
    // ""
;

# vim:ai:sw=4:ts=4:et:syntax=jq