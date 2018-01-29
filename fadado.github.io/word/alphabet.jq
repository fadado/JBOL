module {
    name: "word/alphabet",
    description: "Alphabet operations",
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
#   ALPHABET:   [a]^string
#   WORD:       [a]^string

########################################################################
# Operations on alphabets

# Σⁿ: size n words over an alphabet
# W(n,k) = kⁿ
def power($n): #:: ALPHABET|(number) => *WORD
# assert $n >= 0
    if $n == 0  # Σ⁰
    then .[0:0] # ε
    elif length == 0 # Σ × ∅
    then empty       # ∅
    elif isstring
    then explode|kleene::power($n)|implode
    else kleene::power($n)
    end
;

# Σ*: Σ⁰ ∪ Σ¹ ∪ Σ² ∪ Σ³ ∪ Σ⁴ ∪ Σ⁵ ∪ Σ⁶ ∪ Σ⁷ ∪ Σ⁸ ∪ Σ⁹…
def star: #:: ALPHABET => *WORD
    if length == 0 # ∅
    then .         # ε
    else
        if isstring
        then
            (./"") as $set
            | deepen(""; .+$set[])
        else
            . as $set
            | deepen([]; .[length]=$set[])
        end
    end
# Slow:
#   if length == 0 # ∅
#   then .         # ε
#   else
#       power(range(0; infinite))
#   end
;

# Σ⁺: Σ¹ ∪ Σ² ∪ Σ³ ∪ Σ⁴ ∪ Σ⁵ ∪ Σ⁶ ∪ Σ⁷ ∪ Σ⁸ ∪ Σ⁹…
def plus: #:: ALPHABET => *WORD
    if length == 0 # ∅
    then empty     # ∅
    else
        if isstring
        then
            (./"") as $set
            | deepen($set[]; .+$set[])
        else
            . as $set
            | deepen(.[]|[.]; .[length]=$set[])
        end
    end
# Slow:
#   if length == 0 # ∅
#   then empty     # ∅
#   else
#       power(range(1; infinite))
#   end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
