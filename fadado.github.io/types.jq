module {
    name: "types",
    description: "Common types",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

# Data type predicates
def isnull: type=="null";
def isboolean: type=="boolean";
def isnumber: type=="number";
def isstring: type=="string";
def isarray: type=="array";
def isobject: type=="object";
def isscalar: type| .=="null" or .=="boolean" or .=="number" or .=="string";
def isiterable: type| .=="array" or .=="object";
def isvoid: isiterable and length==0;
def isleaf: isscalar or isvoid;

def isnull($x): $x|isnull;
def isboolean($x): $x|isboolean;
def isnumber($x): $x|isnumber;
def isstring($x): $x|isstring;
def isarray($x): $x|isarray;
def isobject($x): $x|isobject;
def isscalar($x): $x|isscalar;
def isiterable($x): $x|isiterable;
def isvoid($x): $x|isvoid;
def isleaf($x): $x|isleaf;

# Variation on `with_entries`
#
# PAIR: {"name":string, "value":value}
#
def mapobj(f): #:: object|(PAIR->PAIR) -> object
    reduce (keys_unsorted[] as $k
            | {name: $k, value: .[$k]}
            | f
            | {(.name): .value})
            as $pair
        ({}; . + $pair)
;

# Variation on `walk`
#
def mapdoc(f): #:: value|(α->β) -> value
    . as $doc |
    if isobject then
        reduce keys_unsorted[] as $k
            ({}; . + {($k): ($doc[$k]|mapdoc(f))})
        | f
    elif isarray then
        [.[] | mapdoc(f)]
        | f
    else f
    end
;

# Set construction from strings and arrays
#
# SET: {"name": boolean, ...}
#
def set($a): #:: ([α]+string) -> SET
    if $a|isstring
    then
        reduce ($a/"")[] as $element ({}; . += {($element):true})
    else
        reduce $a[] as $element ({}; . += {($element|tostring):true})
    end
;

# Common sets operations
#
def intersection($s): #:: SET|(SET) -> SET
    mapobj(select(.name | in($s)))
;

def difference($s): #:: SET|(SET) -> SET
    mapobj(select(.name | in($s) | not))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
