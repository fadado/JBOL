module {
    name: "word/language",
    description: "Language operations",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

import "fadado.github.io/array/kleene" as kleene;
include "fadado.github.io/prelude";

########################################################################
# Types used in declarations:
#   WORD:       [a]^string
#   LANGUAGE:   [WORD]
#   ε:           "" for string WORD, [] for array WORD

########################################################################
# Operations on languages

# L1 × L2...
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
    then error("language::concat Not defined for zero languages")
    elif any(.[]; length==0) # L × ∅
    else _concat
    end
;

# Lⁿ
def power($n): #:: LANGUAGE|(number) => *WORD
# assert $n >= 0
    if $n == 0 # L⁰
    then .[0][0:0] // [] # ε (defaults to array)
    elif length == 0 # L × ∅
    then empty       # ∅
    else
        . as $lang
        | [range($n) | $lang]
        | concat
    end
;

# L*
def star: #:: LANGUAGE => *WORD
    if length == 0 # ∅ (empty language)
    then []        # ε (returns array as an empty word)
    else power(range(0; infinite))
    end
;

# L⁺
def plus: #:: LANGUAGE => *WORD
    if length == 0 # ∅ (empty language)
    then empty     # ∅
    else power(range(1; infinite))
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
