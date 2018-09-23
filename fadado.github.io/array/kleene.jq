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
#   SET:    [a]
#   TUPLE:  [a]

# ×, A ×, A × B, A × B × C, …
def product: #:: [SET] => *TUPLE
    def _product:
        if length == 1 then
            .[0][] | [.]
        else
            .[0][] as $x
            | [$x] + (.[1:]|_product)
        end
    ;
    if length == 0 # empty product?
    then []        # identity element: empty tuple
    elif some(.[] | length==0) # A × ∅
    then empty # ∅ of tuples
    else _product
    end
;

# Aⁿ
# W(n,k) = kⁿ
def power($n): #:: SET|(number) => +TUPLE
# assert $n >= 0
    if $n == 0 # A⁰
    then [] # empty tuple
    elif length == 0 # A = ∅
    then empty # ∅ of tuples
    else
        . as $set
        | [range(0;$n) | $set]
        | product
    end
;

#def star: #:: string => +string
#    def k: "", .[] + k;
#    if length == 0 then .  else (./"")|k end
#;

# A*: A⁰ ∪ A¹ ∪ A² ∪ A³ ∪ A⁴ ∪ A⁵ ∪ A⁶ ∪ A⁷ ∪ A⁸ ∪ A⁹…
def star: #:: SET => +TUPLE
    if length == 0 # ∅
    then . # ε
    else
        . as $set
        | iterate([]; .[length]=$set[])
    end
# Very slow:
#   if length == 0
#   then .
#   else power(seq)
#   end
;

# A⁺: A¹ ∪ A² ∪ A³ ∪ A⁴ ∪ A⁵ ∪ A⁶ ∪ A⁷ ∪ A⁸ ∪ A⁹…
def plus: #:: SET => *TUPLE
    if length == 0 # ∅
    then empty # ∅ of tuples
    else
        . as $set
        | iterate($set[]|[.]; .[length]=$set[])
    end
# Very slow:
#   if length == 0
#   then empty
#   else power(seq(1))
#   end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
