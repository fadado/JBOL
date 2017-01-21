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
def find($s; $i): find($s; $i; length);
def find($s):     find($s;  0; length);

# Locate characters
def upto($c; $i; $j): #:: string|(string; number;number) -> <number>
    assert($c != ""; "upto requires a non empty string as argument")
    | select($i >= 0 and $i < $j and $i < length and $j <= length)
    | range($i; $j) as $p
    | if .[$p:$p+1] | inside($c)
      then $p
      else empty
      end
;
def upto($c; $i): upto($c; $i; length);
def upto($c):     upto($c;  0; length);

# Match initial string
def match($s; $i): #:: string|(string;number) -> number
    select($i >= 0 and $i < length)
    | if .[$i:]|startswith($s)
      then $i+($s|length)
      else empty
      end
;
def match($s): match($s; 0);

# Locate initial character
def any($c; $i): #:: string|(string;number) -> number
    select($i >= 0 and $i < length)
    | if .[$i:$i+1] | inside($c)
      then $i+1
      else empty
      end
;
def any($c): any($c; 0);

def notany($c; $i): #:: string|(string;number) -> number
    select($i >= 0 and $i < length)
    | if .[$i:$i+1] | inside($c) | not
      then $i+1
      else empty
      end
;
def notany($c): notany($c; 0);

# Locate many characters
def many($c; $i): #:: string|(string;number) -> number
    def _many($s; $n):
        def r:
            if .==$n    # all matched
            then $n
            elif $s[.:.+1]|inside($c)
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
def many($c): many($c; 0);

def none($c; $i): #:: string|(string;number) -> number
    def _none($s; $n):
        def r:
            if .==$n
            then $n
            elif $s[.:.+1]|inside($c)|not
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
def none($c): none($c; 0);

# Pad strings
def left($n; $t): #:: string|(number;string) -> string
    if $n <= length
    then .
    else ($t*($n-length)) + .
    end
;
def left($n): left($n; " ");

def right($n; $t): #:: string|(number;string) -> string
    if $n <= length
    then .
    else . + ($t*($n-length))
    end
;
def right($n): right($n; " ");

def center($n; $t): #:: string|(number;string) -> string
    if $n <= length
    then .
    else
        ((($n-length)/2)|floor) as $i
        | ($t*$i) + . + ($t*$i)
        | if length==$n then . else .+$t end
    end
;
def center($n): center($n; " ");

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
def rot13:
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
def translate($tt): #:: string|(TABLE) -> string
    [ (./"")[] | $tt[.]//. ] | join("")
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

def _lndx(p): # left index or empty if not found
    label $found
    | range(length-1) as $i
    | if .[$i:$i+1]|p
        then empty
        else $i , break $found
        end
;

def _rndx(p): # rigth index or empty if not found
    label $found
    | range(length-1; 0; -1) as $i
    | if .[$i:$i+1]|p
        then empty
        else $i+1 , break $found
        end
;

def lstrip($t): #:: string|(string) -> string
    if length==0 or (.[0:1]|inside($t)|not)
    then .
    else
        (_lndx(inside($t))//-1) as $i
        | if $i < 0 then "" else .[$i:] end
    end
;

def rstrip($t): #:: string|(string) -> string
    if length==0 or (.[-1:length]|inside($t)|not)
    then .
    else
        (_rndx(inside($t))//-1) as $i
        | if $i < 0 then "" else .[0:$i] end
    end
;

def strip($t): #:: string|(string) -> string
    if length==0 or ((.[0:1]|inside($t)) or (.[-1:length]|inside($t)) | not)
    then .
    else
        (_lndx(inside($t))//-1) as $i |
        (_rndx(inside($t))//-1) as $j |
        if $i < 0 and $j < 0 then ""
        elif $j < 0          then .[$i:]
        elif $i < 0          then .[:$j]
                             else .[$i:$j]
        end
    end
;

def trim:  strip(" \t\r\n\f");
def ltrim: lstrip(" \t\r\n\f");
def rtrim: rstrip(" \t\r\n\f");

# vim:ai:sw=4:ts=4:et:syntax=jq
