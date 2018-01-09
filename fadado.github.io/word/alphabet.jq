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

# Σⁿ: size n words over an alphabet
def power($n): #:: ALPHABET|(number) => *WORD
# assert $n >= 0
    if $n == 0  # Σ⁰
    then .[0:0] # ε
    elif length == 0 # Σ × ∅
    then empty       # ∅
    elif type == "string"
    then explode|kleene::power($n)|implode
    else kleene::power($n)
    end
;

# Σ*
def star: #:: ALPHABET => *WORD
    if length == 0 # ∅
    then .         # ε
    else power(range(0; infinite))
    end
;

# Σ⁺
def plus: #:: ALPHABET => *WORD
    if length == 0 # ∅
    then empty     # ∅
    else power(range(1; infinite))
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
