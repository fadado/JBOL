module {
    name: "latin1",
    description: "Functions in the ctype style for the ISO-8859-1 encoding",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

import "fadado.github.io/string/latin1" as $C;

#:: string
def cntrl:  $C::C[0].cntrl;
def space:  $C::C[0].space;
def blank:  $C::C[0].blank;
def upper:  $C::C[0].upper;
def lower:  $C::C[0].lower;
def alpha:  $C::C[0].alpha;  # alphabet, first lower
def ALPHA:  $C::C[0].ALPHA;  # alphabet, first upper
def digit:  $C::C[0].digit;
def xdigit: $C::C[0].xdigit;
def punct:  $C::C[0].punct;
def alnum:  $C::C[0].alnum;
def graph:  $C::C[0].graph;
def print:  $C::C[0].print;

#:: string| -> boolean
def isascii:    every(explode[] | . <= 127);
def islatin1:   every(explode[] | . > 159 and . < 256);
def isvacant:   every(explode[] | . > 127 and . < 160);
def iscntrl:    every((./"")[] | $C::C[0].iscntrl[.]//false);
def isspace:    every((./"")[] | $C::C[0].isspace[.]//false);
def isblank:    every((./"")[] | . == " " or . == "\t" or . == "\u00a0");
def isupper:    every((./"")[] | $C::C[0].isupper[.]//false);
def islower:    every((./"")[] | $C::C[0].islower[.]//false);
def isdigit:    every((./"")[] | $C::C[0].isdigit[.]//false);
def isxdigit:   every((./"")[] | $C::C[0].isxdigit[.]//false);
def ispunct:    every((./"")[] | $C::C[0].ispunct[.]//false);
def isalpha:    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false);
def isalnum:    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false or $C::C[0].isdigit[.]//false);
def isgraph:    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false or $C::C[0].isdigit[.]//false or $C::C[0].ispunct[.]//false);
def isprint:    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false or $C::C[0].isdigit[.]//false or $C::C[0].ispunct[.]//false or . == " " or . == "\t" or . == "\u00a0");
def isword:     every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false or $C::C[0].isdigit[.]//false or . == "_" or . == "·");

def tolower: #:: string| -> string
    [(./"")[] | $C::C[0].tolower[.]//.] | join("")
;

def toupper: #:: string| -> string
    [(./"")[] | $C::C[0].toupper[.]//.] | join("")
;

# Translation tables
#
#:: {string: string}
def ttlower:      $C::C[0].tolower;
def ttupper:      $C::C[0].toupper;

# vim:ai:sw=4:ts=4:et:syntax=jq
