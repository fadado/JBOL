module {
    name: "word/language",
    description: "Language operations",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/array/kleene" as kleene;

########################################################################
# Types used in declarations:
#   WORD:       [a]^string
#   LANGUAGE:   [WORD]
#   ε:           "" for string WORD, [] for array WORD

########################################################################
# Operations on languages

# L, L1 × L2, L1 × L2 × L3, ...
def concat: #:: [LANGUAGE] => *WORD
    def _concat:
        if length == 1
        then
            .[0][]
        else
            .[0][] as $x
            | $x + (.[1:]|_concat)
        end
    ;
    if length == 0
    then error("language::concat not defined for zero languages")
    elif any(.[]; length==0) # L × ∅
    then empty               # ∅
    else _concat
    end
;

# Lⁿ
def power($n; $epsilon): #:: LANGUAGE|(number;WORD) => *WORD
# assert $n >= 0
    if $n == 0 # L⁰
    then .[0][0:0] // $epsilon # ε
    elif length == 0 # L × ∅
    then empty       # ∅
    else
        . as $lang
        | [range($n) | $lang]
        | concat
    end
;
def power($n): #:: LANGUAGE|(number) => *WORD
# assert $n >= 0
    power($n;[]) # empty WORD defaults to array
;

# L*
def star($epsilon): #:: LANGUAGE|(WORD) => *WORD
# TODO: implement using `deepen`
    if length == 0 # ∅ (empty language)
    then .[0][0:0] // $epsilon # ε
    else power(range(0; infinite))
    end
;
def star: #:: LANGUAGE => *WORD
    star([]) # empty WORD defaults to array
;

# L⁺
def plus: #:: LANGUAGE => *WORD
# TODO: implement using `deepen`
    if length == 0 # ∅ (empty language)
    then empty     # ∅
    else power(range(1; infinite))
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
