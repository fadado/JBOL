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
include "fadado.github.io/types";
import "fadado.github.io/array/kleene" as kleene;

########################################################################
# Types used in declarations:
#   WORD:       [a]^string
#   LANGUAGE:   [WORD]
#   ε:           "" for string WORD, [] for array WORD

# Fibbonacci strings language
# fibstr("a"; "b") => "a","b","ab","bab","abbab"…
def fibstr($w; $u): #:: (WORD;WORD) => +WORD
    [$w,$u]
    | recurse([.[-1], .[-2]+.[-1]])
    | .[-2]
;

########################################################################
# Operations on languages

# L, L1 × L2, L1 × L2 × L3, ...
def concat: #:: [LANGUAGE] => *WORD
    def _concat:
        if length == 1 then
            .[0][]
        else
            .[0][] as $x
            | $x + (.[1:]|_concat)
            # reverse order: .[0][] + (.[1:]|_concat)
        end
    ;
    if length == 0 # ×
    then error("language::concat cannot determine ε for empty languages")
    elif some(.[] | length==0) # L × ∅
    then empty # ∅ of words
    else _concat
    end
;

# Lⁿ
def power($n): #:: LANGUAGE|(number) => *WORD
# assert $n >= 0
    if $n == 0 then # L⁰
        if length > 0
        then .[0][0:0] # ε
        else error("language::power cannot determine ε for empty languages")
        end
    elif length == 0 # L = ∅
    then empty # ∅ of words
    elif isstring(.[0]) or isarray(.[0]) then
        . as $lang
        | [range(0;$n) | $lang]
        | concat
    else .[0]|typerror("string or array")
    end
;

# L*
def star: #:: LANGUAGE => *WORD
    if length == 0 then # ∅ (empty language)
        error("language::star cannot determine ε for empty languages")
    elif isstring(.[0]) then
        . as $lang | iterate(""; .+$lang[])
    elif isarray(.[0]) then
        . as $lang | iterate([]; .+$lang[])
    else .[0]|typerror("string or array")
    end
;

# L⁺
def plus: #:: LANGUAGE => *WORD
    if length == 0 then # ∅ (empty language)
        empty # ∅
    elif isstring(.[0]) or isarray(.[0]) then
        . as $lang | iterate($lang[]; .+$lang[])
    else .[0]|typerror("string or array")
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
