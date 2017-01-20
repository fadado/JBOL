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

import "fadado.github.io/string/ascii" as ascii;

########################################################################
# Icon style text operations 

# Generates the stream of integer positions in the input string at which
# `needle` inside the string occurs as a substring, or nothing if there is no
# such position.
#
def find($needle): #:: string|(string) -> <number>
    indices($needle)[]
;

# Generates the sequence of integer positions in the input string preceding a
# character of `c` in `.[i:j]`. It fails if there is no such
# position.
def upto($c; $i; $j): #:: string|(string; number;number) -> <number>
    select($i < length and $j <= length and $i < $j)
    | range($i; $j) as $p
    | if .[$p:$p+1] | inside($c)
      then $p
      else empty
      end
;
def upto($c; $i): upto($c; $i; length);
def upto($c):     upto($c;  0; length);

def lpad($s; $n; $t): #:: (string;number;string) -> string
    ($s|length) as $len
    | if $n <= $len
      then $s
      else ($t*($n-$len)) + $s
      end
;
def lpad($s; $n): lpad($s; $n; " ");

def rpad($s; $n; $t): #:: (string;number;string) -> string
    ($s|length) as $len
    | if $n <= $len
      then $s
      else $s + ($t*($n-$len))
      end
;
def rpad($s; $n): rpad($s; $n; " ");

########################################################################
# Classical conversions

# Produces an integer (ordinal) that is the internal representation of the
# first character in `s`
#
def ord: #:: string| -> number
    .[0:1]|explode[0]
;
def ord($s): #:: (string) -> number
    $s[0:1]|explode[0]
;

# Produces a string of length 1 consisting of the character whose internal
# representation is `n`
#
def chr: #:: number| -> string
    [.]|implode
;
def chr($n): #:: (number) -> string
    [$n]|implode
;

########################################################################
# Positional manipulations

# Rotate strings in both directions
#
def rotate($s; $n): #:: (string; number) -> string
    $s[$n:] + $s[:$n]
;

def rotate($n): #:: string|(number) -> string
    rotate(.; $n)
;

# Reverse characters in string
#
def reverse($s): #:: (string) -> string
    $s|explode|reverse|implode
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
# Classical BASIC trim and Python strip

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

def ltrim: #:: string| -> string
    lstrip(" \t\r\n\f")
;

def rtrim: #:: string| -> string
    rstrip(" \t\r\n\f")
;

def trim: #:: string| -> string
   strip(" \t\r\n\f")
;

# vim:ai:sw=4:ts=4:et:syntax=jq
