module {
    name: "object/set",
    description: "Objects managed as sets",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";

# Variation on `with_entries`
#
# PAIR: {"name":string, "value":value}
#
def mapobj(filter): #:: object|(PAIR->PAIR) => object
    reduce (keys_unsorted[] as $k
            | {name: $k, value: .[$k]}
            | filter
            | {(.name): .value})
        as $pair ({}; . + $pair)
;

########################################################################
# Objects as sets
#
# SET: {"element": boolean, ...}
#
# ∅         {}
# |s|       length
# {e...}    set([e...])
# s + e     s | .e=true
# s + e     s += {e: true}
# s – e     s | del(.e)
# e ∈ s     e | in(s)
# e ∉ s     e | in(s) | not
# s ∋ e     s | has(e)
# s ∋ e     s | .e
# s ∌ e     s | .e == null
# s ≡ t     s == t
# s ≢ t     s != t
# s ∪ t     s + t
# s ∪ t     s * t
# s ∩ t     s | intersection(t)
# s – t     s | difference(t)

# Set construction from strings and arrays
#
def set: #:: string^[a]| => {boolean}
    if isstring then
        reduce (./"")[] as $element
            ({}; . += {($element):true})
    elif isarray then
        reduce .[] as $element
            ({}; . += {($element|tostring):true})
    else typerror("string or array")
    end
;
def set($elements): #:: (string^[a]) => {boolean}
    $elements | set
;

# Common sets operations
#
def intersection($other): #:: {boolean}|({boolean}) => {boolean}
    mapobj(select(.name | in($other)))
;

def difference($other): #:: {boolean}|({boolean}) => {boolean}
    mapobj(reject(.name | in($other)))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
