module {
    name: "array/kleene",
    description: "Kleene closure for arrays as sets",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

########################################################################
# Types used in declarations:
#   SET: [a]
#   TUPLE: [a]
#   WORD: [a]^string
#   IDENTITY: "" or []

# ×, A ×, A × B, A × B × C, …
# Generates tuples
def product: #:: [SET] => +TUPLE
    def _product:
        if length == 1
        then
            .[0][] | [.]
        else
            .[0][] as $x
            | [$x] + (.[1:]|_product)
        end
    ;
    if length == 0
    then [] # empty tuple
    elif any(.[]; length==0) # A × ∅
    then empty
    else _product
    end
;

# For sets with catenable symbols (arrays or strings)
# Generates words
# Note: empty array or string must be specified as identity value
def product($identity): #:: [SET]|(IDENTITY) => +WORD
    def _product:
        if length == 1
        then
            .[0][]
        else
            .[0][] as $x
            | $x + (.[1:]|_product)
        end
    ;
    if length == 0
    then $identity
    elif any(.[]; length==0)
    then empty
    else _product
    end
;

# Aⁿ
# Specifically size n words over an alphabet Σ (Σⁿ)
# W(n,k) = k^n
def power($n): #:: SET|(number) => +TUPLE
    select(0 <= $n) # not defined for negative $n
    | . as $set
    | [range($n) | $set]
    | product
;

def power($n; $identity): #:: SET|(number;IDENTITY) => +WORD
    select(0 <= $n) # not defined for negative $n
    | . as $set
    | [range($n) | $set]
    | product($identity)
;

# Generates K*: K⁰ ∪ K¹ ∪ K² ∪ K³ ∪ K⁴ ∪ K⁵ ∪ K⁶ ∪ K⁷ ∪ K⁸ ∪ K⁹…
# Specifically, words over an alphabet Σ (Σ*: Σ⁰ ∪ Σ¹ ∪ Σ²…)
def star: #:: SET => +TUPLE
    power(range(0; infinite))
#   . as $set
#   | if length == 0
#   then []
#   else []|deepen(.[length]=$set[])
#   end
;

# For catenable symbols
def star($identity): #:: SET|(IDENTITY) => +WORD
    power(range(0; infinite); $identity)
#   . as $set
#   | if length == 0
#   then $identity
#   else $identity|deepen(. + $set[])
#   end
;

#def star: #:: string => +string
#    def k: "", .[] + k;
#    if length == 0 then .  else (./"")|k end
#;

# Generates K⁺: K¹ ∪ K² ∪ K³ ∪ K⁴ ∪ K⁵ ∪ K⁶ ∪ K⁷ ∪ K⁸ ∪ K⁹…
# Specifically, words over an alphabet Σ without empty word (Σ⁺: Σ¹ ∪ Σ²…)
def plus: #:: SET => *TUPLE
    power(range(1; infinite))
#   . as $set
#   | if length == 0
#   then empty
#   else deepen(.[]|[.]; .[length]=$set[])
#   end
;

# For catenable symbols ($identity is ignored!)
def plus($identity): #:: SET|(IDENTITY) => *WORD
    power(range(1; infinite); $identity)
#   . as $set
#   | if length == 0
#   then empty
#   else deepen(.[]; . + $set[])
#   end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
