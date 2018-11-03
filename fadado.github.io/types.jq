module {
    name: "types",
    description: "Type predicates and utilities",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

#
# Data type predicates
#

# querying .
def isnull: #:: a => boolean
    type == "null"
;
def isboolean: #:: a => boolean
    type == "boolean"
;
def isnumber: #:: a => boolean
    type == "number"
;
def isinteger: #:: a => boolean
    type == "number" and . == trunc
;
def isreal: #:: a => boolean
    type == "number" and . != trunc
;
def isstring: #:: a => boolean
    type == "string"
;
def ischar: #:: a => boolean
    type == "string" and length == 1
;
def isarray: #:: a => boolean
    type == "array"
;
def isobject: #:: a => boolean
    type == "object"
;
def isscalar: #:: a => boolean
    type| . == "null" or . == "boolean" or . == "number" or . == "string"
;
def isiterable: #:: a => boolean
    type| . == "array" or . == "object"
;
def isvoid: #:: a => boolean
    isiterable and length == 0
;
def nonvoid: #:: a => boolean
    isiterable and length > 0
;

# querying parameter
def isnull($a): #:: (a) => boolean
    $a|type == "null"
;
def isboolean($a): #:: (a) => boolean
    $a|type == "boolean"
;
def isnumber($a): #:: (a) => boolean
    $a|type == "number"
;
def isinteger($a): #:: (a) => boolean
    $a|type == "number" and . == trunc
;
def isreal($a): #:: (a) => boolean
    $a|type == "number" and . != trunc
;
def isstring($a): #:: (a) => boolean
    $a|type == "string"
;
def ischar($a): #:: (a) => boolean
    $a|type == "string" and length == 1
;
def isarray($a): #:: (a) => boolean
    $a|type == "array"
;
def isobject($a): #:: (a) => boolean
    $a|type == "object"
;
def isscalar($a): #:: (a) => boolean
    $a|type| . == "null" or . == "boolean" or . == "number" or . == "string"
;
def isiterable($a): #:: (a) => boolean
    $a|type| . == "array" or . == "object"
;
def isvoid($a): #:: (a) => boolean
    $a|isiterable and length == 0
;
def nonvoid($a): #:: (a) => boolean
    $a|isiterable and length > 0
;

# coerce to bool (exactly true or false)
def tobool: #:: a => boolean
    if . then true else false end
;
# coerce also empty to false
def tobool(a): #:: (a) => boolean
#   (first(a)|tobool) // false
    if first(a) // false then true else false end
;

# Path expressions
def ispath(x):
    try (isempty(path(x)) or true)
    catch false
;

def isvalue(x):
    try (path(x)//null | false)
    catch true
;

# Type errors

def typerror:
    type | error("Type error: unexpected \(.)")
;

def typerror($s):
    type | error("Type error: expected" + $s + ", not \(.)")
;

# vim:ai:sw=4:ts=4:et:syntax=jq
