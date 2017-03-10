module {
    name: "types",
    description: "Common types",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

# Data type predicates
def isnull: #:: α| -> boolean
    type == "null"
;
def isboolean: #:: α| -> boolean
    type == "boolean"
;
def isnumber: #:: α| -> boolean
    type == "number"
;
def isstring: #:: α| -> boolean
    type == "string"
;
def isarray: #:: α| -> boolean
    type == "array"
;
def isobject: #:: α| -> boolean
    type == "object"
;
def isscalar: #:: α| -> boolean
    type| . == "null" or . == "boolean" or . == "number" or . == "string"
;
def isiterable: #:: α| -> boolean
    type| . == "array" or . == "object"
;
def isvoid: #:: α| -> boolean
    isiterable and length == 0
;
def isleaf: #:: α| -> boolean
    isscalar or isvoid
;

def isnull($a): #:: (α) -> boolean
    $a|isnull
;
def isboolean($a): #:: (α) -> boolean
    $a|isboolean
;
def isnumber($a): #:: (α) -> boolean
    $a|isnumber
;
def isstring($a): #:: (α) -> boolean
    $a|isstring
;
def isarray($a): #:: (α) -> boolean
    $a|isarray
;
def isobject($a): #:: (α) -> boolean
    $a|isobject
;
def isscalar($a): #:: (α) -> boolean
    $a|isscalar
;
def isiterable($a): #:: (α) -> boolean
    $a|isiterable
;
def isvoid($a): #:: (α) -> boolean
    $a|isvoid
;
def isleaf($a): #:: (α) -> boolean
    $a|isleaf
;

# Variation on `with_entries`
#
# PAIR: {"name":string, "value":value}
#
def mapobj(filter): #:: object|(PAIR->PAIR) -> object
    reduce (keys_unsorted[] as $k
            | {name: $k, value: .[$k]}
            | filter
            | {(.name): .value})
            as $pair
        ({}; . + $pair)
;

# Variation on `walk`
#
def mapdoc(filter): #:: α|(β->γ) -> α
    . as $doc |
    if isobject then
        reduce keys_unsorted[] as $k
            ({}; . + {($k): ($doc[$k] | mapdoc(filter))})
        | filter
    elif isarray then
        [.[] | mapdoc(filter)]
        | filter
    else filter
    end
;

# Generates a document schema
#
def schema: #:: α| -> SCHEMA
    if isobject then
        if length == 0 then
            {"type": "object"}  # properties: null?
        else
            . as $object |
            {"type": "object"}
            + {"properties": (
                reduce keys_unsorted[] as $name ({};
                    . + {($name): ($object[$name] | schema)}
                )
              )
            }
        end
    elif isarray then
        if length == 0 then
            {"type": "array"}   # items: null?
        else
            {"type": "array"}
            + {"items": (
                if all(isscalar) and (map(type)|unique|length) == 1 then
                    {"type": (.[0] | type)}
                else
                    reduce .[] as $item ([];
                        .[length] = ($item | schema)
                    )
                end
              )
            }
        end
    else # scalar
        {"type": type}
    end
;

# vim:ai:sw=4:ts=4:et:syntax=jq
