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

# ε
def _epsilon:
    # is first word in . a string or is an array?
    .[0]|type |
    if . == "string"
    then ""
    elif . == "array"
    then []
    else "Type error: expected string or array, not \(.)" | error
    end
;

# L1 × L2
def product($l1; $l2): #:: (LANGUAGE;LANGUAGE) => *WORD
    if $l1 == [] or $l2 == []
    then empty
    else
        ($l1|_epsilon) as $e
        | [$l1,$l2]|kleene::product($e)
    end
;

# Lⁿ
def power($n): #:: LANGUAGE|(number) => *WORD
    if length == 0 # empty language
    then empty
    else kleene::power($n; _epsilon)
    end
;

# L*
def star: #:: LANGUAGE => *WORD
    if length == 0 # empty language
    then empty
    else kleene::star(_epsilon)
    end
;

# L⁺
def plus: #:: LANGUAGE => *WORD
    if length == 0 # empty language
    then empty
    else kleene::plus(_epsilon)
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
