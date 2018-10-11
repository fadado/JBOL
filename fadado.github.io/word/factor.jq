module {
    name: "word/factor",
    description: "Operations on word factors",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

import "fadado.github.io/word/scanner" as scan;

########################################################################
# Types used in declarations:
#   WORD:       [a]^string
#   POSITION:   number

########################################################################
# Match one word

# Prefix?
def isprefix($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | $j <= length and .[0:$j] == $u
;

# Suffix?
def issuffix($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | $j == 0 or $j <= length and .[-$j:] == $u
;

# Factor?
def isfactor($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | 0 < $j and index($u)!=null
;

# Proper prefix?
def ispprefix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and isprefix($u)
;

# Proper suffix?
def ispsuffix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and issuffix($u)
;

# Proper factor?
def ispfactor($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | 0 < $j and $j < length and index($u)!=null
;

########################################################################
# Word streams

# Sets of prefixes (without the empty word)
def prefixes: #:: WORD => *WORD
    .[:range(1;length+1)]
;

# Sets of suffixes (without the empty word)
def suffixes: #:: WORD => *WORD
    .[range(length-1;-1;-1):]
;

# Sets of factors, (without the empty word)
def factors: #:: WORD => *WORD
# length order:
    range(1;length+1) as $j
    | range(0;length-$j+1) as $i
    | .[$i:$i+$j]
# different order:
#   range(0;length+1) as $i
#   | range($i+1; length+1) as $j
#   | .[$i:$j]
;

########################################################################
# Tokenize words

# Produce tokens delimited by `$wset` symbols
def tokens($w; $wset): #:: POSITION|(WORD;WORD) => *WORD
    def r:
        scan::upto1_c($w; $wset)      # [delimiters]*(?=[^delimiters])
        | . as $i
        | scan::many_c($w; $wset)     # [^delimiters]+
        | $w[$i:.], r
    ;
    r
;
# Produce tokens consisting in `$wset` symbols
def tokens_c($w; $wset): #:: POSITION|(WORD;WORD) => *WORD
    def r:
        scan::upto1($w; $wset)    # [^consisting]*(?=[consisting])
        | . as $i
        | scan::many($w; $wset)   # [consisting]+
        | $w[$i:.], r
    ;
    r
;

# vim:ai:sw=4:ts=4:et:syntax=jq
