module {
    name: "string/latin1",
    description: "Functions in the ctype style for the ISO-8859-1 encoding",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/string/latin1" as $C;

def cntrl: #:: string
    $C::C[0].cntrl
;
def space: #:: string
    $C::C[0].space
;
def blank: #:: string
    $C::C[0].blank
;
def upper: #:: string
    $C::C[0].upper
;
def lower: #:: string
    $C::C[0].lower
;
def alpha: #:: string
    $C::C[0].alpha # alphabet, first lower
;
def ALPHA: #:: string
    $C::C[0].ALPHA # alphabet, first upper
;
def digit: #:: string
    $C::C[0].digit
;
def xdigit: #:: string
    $C::C[0].xdigit
;
def punct: #:: string
    $C::C[0].punct
;
def alnum: #:: string
    $C::C[0].alnum
;
def graph: #:: string
    $C::C[0].graph
;
def print: #:: string
    $C::C[0].print
;

def isascii: #:: string => boolean
    every(explode[] <= 127)
;
def islatin1: #:: string => boolean
    every(explode[] | . > 159 and . < 256)
;
def isvacant: #:: string => boolean
    every(explode[] | . > 127 and . < 160)
;
def iscntrl: #:: string => boolean
    every(explode[] | . < 32 or . == 127)
;
def isspace: #:: string => boolean
    every($C::C[0].isspace[(./"")[]]//false)
;
def isblank: #:: string => boolean
    every((./"")[] | . == " " or . == "\t" or . == "\u00a0")
;
def isupper: #:: string => boolean
    every($C::C[0].isupper[(./"")[]]//false)
;
def islower: #:: string => boolean
    every($C::C[0].islower[(./"")[]]//false)
;
def isdigit: #:: string => boolean
    every($C::C[0].isdigit[(./"")[]]//false)
;
def isxdigit: #:: string => boolean
    every($C::C[0].isxdigit[(./"")[]]//false)
;
def ispunct: #:: string => boolean
    every($C::C[0].ispunct[(./"")[]]//false)
;
def isalpha: #:: string => boolean
    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false)
;
def isalnum: #:: string => boolean
    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false or $C::C[0].isdigit[.]//false)
;
def isgraph: #:: string => boolean
    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false or $C::C[0].isdigit[.]//false or $C::C[0].ispunct[.]//false)
;
def isprint: #:: string => boolean
    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false or $C::C[0].isdigit[.]//false or $C::C[0].ispunct[.]//false or . == " " or . == "\t" or . == "\u00a0")
;
def isword: #:: string => boolean
    every((./"")[] | $C::C[0].isupper[.]//false or $C::C[0].islower[.]//false or $C::C[0].isdigit[.]//false or . == "_" or . == "·")
;

def tolower: #:: string => string
    mapstr($C::C[0].tolower[.]//.)
;

def toupper: #:: string => string
    mapstr($C::C[0].toupper[.]//.)
;

# Translation tables
#
def tt_tolower: #:: {string}
    $C::C[0].tolower
;
def tt_toupper: #:: {string}
    $C::C[0].toupper
;

# vim:ai:sw=4:ts=4:et:syntax=jq
