module {
    name: "table",
    description: "Translation tables in the SNOBOL language style",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/string/ascii" as ascii;
import "fadado.github.io/object/set" as set;

########################################################################
# Translation tables

# Translate/remove tables
def new($from; $to): #:: (string;string) => {string}
   ($from/"") as $s
   | ($to/"") as $t
   | reduce range(0;$s|length) as $i
        ({}; . += {($s[$i]):($t[$i] // "")})
;

# Preserve tables
def preserve($from; $preserve): #:: (string;string) => {string}
   set::new($preserve) as $t
   | reduce (($from/"") | unique)[] as $c
        ({}; . += (if $t[$c] then null else {($c):""} end))
;

# Translate characters in input string using translation table
def translate($table): #:: string|({string}) => string
    reduce ((./"")[] | $table[.]//.) as $s
        (""; . + $s)
;

def translate($from; $to): #:: string|(string;string) => string
    translate(new($from; $to))
;

# Translation table for rotate by 13 places
def rot13: #:: {string}
    def rotate: .[13:] + .[:13];
    new(ascii::ALPHA;
        (ascii::upper|rotate) + (ascii::lower|rotate))
;

# tolower:  s|translate(ascii::ttlower)
# toupper:  s|translate(latin1::ttupper)
# rot13:    s|translate(rot13)
# toggle:   s|translate(new(ascii::ALPHA; ascii::alpha))
# remove:   s|translate("to delete"; "")
# preserve: s|translate(s|translate("to preserve"; "")); "")
# preserve: s|translate(preserve(s; "to preserve"))

########################################################################
# Roman numerals encoding and decoding

# TODO: move to roman.jq

def roman_encode: #:: number => string
    def _toroman($number; $digit; $up):
        def div: (. / 10) | trunc;
        def mod: . % 10;
        def shift: mapstr($up[.]);
        def r:
            if . < 10
            then $digit[.]
            else ((div|r)|shift) + $digit[mod]
            end
        ;
        $number|r
    ;
    assert(0 < . and . < 4000; "Roman numeral out of range")
    | ["","I","II","III","IV","V","VI","VII","VIII","IX"] as $digit
    | {"I":"X","V":"L","X":"C","L":"D","C":"M"} as $up
    | _toroman(.; $digit; $up)
;

def roman_encode($number): #:: (number) => string
    $number|roman_encode
;

# vim:ai:sw=4:ts=4:et:syntax=jq
