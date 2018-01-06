module {
    name: "word/alphabet",
    description: "Alphabet operations",
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
#   ALPHABET:   [a]^string
#   WORD:       [a]^string

########################################################################
# Operations on alphabets

# Σⁿ
def power($n): #:: ALPHABET|(number) => *WORD
    if length == 0 # empty alphabet
    then empty
    elif type == "string"
    then (./"")|kleene::power($n; "")
    else kleene::power($n)
    end
;

# Σ*
def star: #:: ALPHABET => *WORD
    if length == 0 # empty alphabet
    then empty
    elif type == "string"
    then (./"")|kleene::star("")
    else kleene::star
    end
;

# Σ⁺
def plus: #:: ALPHABET => *WORD
    if length == 0 # empty alphabet
    then empty
    elif type == "string"
    then (./"")|kleene::plus("")
    else kleene::plus
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
