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
def isinteger: #:: α| -> boolean
    type == "number" and . == floor
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
def isinteger($a): #:: (α) -> boolean
    $a|isinteger
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

# Generates a simple document schema
#
def schema: #:: α| -> SCHEMA
    { "type": type } +
    if isobject then
        if length == 0 then null
        else
            . as $object |
            { "properties": (
                reduce keys_unsorted[] as $name (
                    {};
                    . + {($name): ($object[$name] | schema)}
                )
              )
            }
        end
    elif isarray then
        if length == 0 then null
        else
            { "items": (
                if every(.[] | isscalar) and ([.[] | type] | unique | length) == 1 then
                    { "type": (.[0] | type) }
                elif length == 1 then
                   .[0] | schema 
                else
                    reduce .[] as $item (
                        [];
                        .[length] = ($item | schema)
                    )
                end
              )
            }
        end
    else null end # scalar
;

# Validates a document against a simple schema
#
def valid($schema): #:: α|(SCHEMA) -> boolean
    #
    # Schema keywords
    #
    def k_type: # keyword type
        if $schema | has("type") then
            type as $t
            | if ($schema["type"] | type) == "string" # string or array
              then $t == $schema["type"] or ($schema["type"] == "integer" and isinteger)
              else some(($schema["type"][] | type) == $t)
              end
        else true end
    ;
    def k_enum: # keyword enum
        if $schema | has("enum") then
            . as $instance
            | isscalar and ($schema.enum | indices([$instance]) | length) > 0
        else true end
    ;
    def k_allOf: # keyword allOf
        if $schema | has("allOf") then
            every(valid($schema.allOf[]))
        else true end
    ;
    def k_anyOf: # keyword anyOf
        if $schema | has("anyOf") then
            some(valid($schema.anyOf[]))
        else true end
    ;
    def k_oneOf: # keyword oneOf
        if $schema | has("oneOf") then
            [valid($schema.oneOf[])] == [true]
        else true end
    ;
    def k_not: # keyword not
        if $schema | has("not") then
            valid($schema.not) | not
        else true end
    ;
    #
    # Type constraints
    #
    def c_number: # number constraints
        if $schema | has("multipleOf") then
            (. / $schema.multipleOf) | . == floor
        else true end
        and if $schema | has("maximum") then
            $schema.maximum as $n
            | if $schema.exclusiveMaximum then . < $n else . <= $n end
        else true end
        and if $schema | has("minimum") then
            $schema.minimum as $n
            | if $schema.exclusiveMinimum then . > $n else . >= $n end
        else true end
    ;
    def c_string: # string constraints
        if $schema | has("maxLength") then
            length <= $schema.maxLength
        else true end
        and if $schema | has("minLength") then
            length >= $schema.minLength
        else true end
        and if $schema | has("pattern") then
            test($schema.pattern)
        else true end
        and if $schema | has("format") then
            error("Keyword 'format' not supported")
        else true end
    ;
    def c_array: # array constraints

        if $schema | has("items") then
            if ($schema.items | isobject) then
                every(.[] | valid($schema.items))
            else # array: tuple validation
                ($schema.items|length) as $len
                | if ($schema.additionalItems == false) and length != $len
                then false
                else
                    every(
                        range($len) as $i
                        | (.[$i] | valid($schema.items[$i]))
                    )
                end
            end
            and if $schema | has("maxItems") then
                length <= $schema.maxItems
            else true end
            and if $schema | has("minItems") then
                length >= $schema.minItems
            else true end
            and if $schema | has("uniqueItems") then
                ($schema.uniqueItems | not) or length == (unique | length)
            else true end
        else true end
    ;
    def c_object: # object constraints
        . as $instance
        | if $schema | has("properties") then
            if $schema | has("maxProperties") then
                . <= $schema.maxProperties
            else true end
            and if $schema | has("minProperties") then
                . >= $schema.minProperties
            else true end
            and if $schema | has("required") then
                every($instance | has($schema.required[]))
            else true end
            and if $schema | has("additionalProperties") then
                $schema.additionalProperties as $p
                | if $p == false then
                    every($schema.properties | has(keys_unsorted[]))
                elif isobject($p) then
                    every(
                        keys_unsorted[]
                        | select(in($schema.properties) | not)
                        | $instance[.] | valid($p)
                    )
                else true end
            else true end
            and every(
                keys_unsorted[] as $k
                | (.[$k] | valid($schema.properties[$k]))
            )
        else true end
    ;
    #
    # Validate
    #
    if $schema == null or $schema == {}
    then true
    else
        k_type  and
        k_enum  and
        k_allOf and
        k_anyOf and
        k_oneOf and
        k_not   and
        if isnumber then c_number
        elif isstring then c_string
        elif isarray then c_array
        elif isobject then c_object
        else true end # null, boolean
    end # empty or null schema
;

# vim:ai:sw=4:ts=4:et:syntax=jq
