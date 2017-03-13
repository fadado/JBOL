#
# Validates an instance document against a JSON schema.
#
include "fadado.github.io/prelude";
include "fadado.github.io/types";

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
    def c_object: # object constraints
        if $schema | has("properties") then
            every(
                keys_unsorted[] as $k
                | (.[$k] | valid($schema.properties[$k]))
            )
        else true end
        and if $schema | has("required") then
            . as $instance
            | every(
                $schema.required[] as $r
                | ($instance | has($r))
            )
        else true end
        and if $schema | has("additionalProperties") then
            $schema.additionalProperties  as $p
            | if $p == false then
                every(
                    keys_unsorted[] as $k
                    | ($schema.properties | has($k))
                )
              elif isobject($p) then
                . as $instance
                | every(
                    keys_unsorted[]
                    | select(in($schema.properties) | not)
                    ($instance[.] | valid($p))
                  )
              # TODO: patternProperties 
              else true end
        else true end
        and if $schema | has("minProperties") then
            . >= $schema.minProperties
        else true end
        and if $schema | has("maxProperties") then
            . <= $schema.maxProperties
        else true end
        # TODO: dependencies
    ;
    def c_array: # array constraints
        if $schema | has("items") then
            if ($schema.items | isobject) then # object or array
                every(.[] | valid($schema.items))
            else # tuple validation
                ($schema.items|length) as $len
                | if ($schema.additionalItems|not) and length != $len then
                    false
                else
                    every(
                        range($len) as $i
                        | (.[$i] | valid($schema.items[$i]))
                    )
                end
            end
        else true end
        and if $schema | has("uniqueItems") then
            length == (unique|length)
        else true end
        and if $schema | has("minItems") then
            . >= $schema.minItems
        else true end
        and if $schema | has("maxItems") then
            . <= $schema.maxItems
        else true end
    ;
    def c_string: # string constraints
        if $schema | has("pattern") then
            test($schema.pattern)
        else true end
        and if $schema | has("minLength") then
            . >= $schema.minLength
        else true end
        and if $schema | has("maxLength") then
            . <= $schema.maxLength
        else true end
        and if $schema | has("format") then
            error("Keyword 'format' not supported")
        else true end
    ;
    def c_number: # number constraints
        if $schema | has("multipleOf") then
            (. % $schema.multipleOf) == 0
        else true end
        and if $schema | has("minimum") then
            $schema.minimum as $n
            | if $schema.exclusiveMinimum then . > $n else . >= $n end
        else true end
        and if $schema | has("maximum") then
            $schema.maximum as $n
            | if $schema.exclusiveMaximum then . < $n else . <= $n end
        else true end
    ;
    #
    # Validate
    #
    def check(a):
        if a then true else
            "Validation error. Instance: \(.); Schema: \($schema)"
            | error
        end
    ;
    if $schema != null and $schema != {} then
        check(k_type)  and
        check(k_enum)  and
        check(k_allOf) and
        check(k_anyOf) and
        check(k_oneOf) and
        check(k_not)   and
        if isobject then check(c_object)
        elif isarray then check(c_array)
        elif isstring then check(c_string)
        elif isnumber then check(c_number)
        else true end # null or boolean
    else true end # empty or null schema
;

# Main
#
$SCHEMA[0] as $schema
| if $schema | has("$schema") | not then
    "Expected '$schema' property in root instance"
  else
    try (valid($schema) | "") catch .
  end


# vim:ai:sw=4:ts=4:et:syntax=jq
