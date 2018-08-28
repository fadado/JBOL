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
def set($elements): #:: (string^[a]) => {boolean}
    $elements
    | if type=="string" then
        reduce ($elements/"")[] as $element
            ({}; . += {($element):true})
    elif type=="array" then
        reduce $elements[] as $element
            ({}; . += {($element|tostring):true})
    else type | "Type error: expected string or array, not \(.)" | error
    end
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
