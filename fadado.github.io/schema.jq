module {
    name: "schema",
    description: "Schema generation and validation",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";

# Generates a simple document schema
#
def generate: #:: α| -> SCHEMA
    { "type": type } +
    if isobject then
        if length == 0 then null
        else
            . as $object |
            { "properties": (
                reduce keys_unsorted[] as $name (
                    {};
                    . + {($name): ($object[$name] | generate)}
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
                   .[0] | generate 
                else
                    reduce .[] as $item (
                        [];
                        .[length] = ($item | generate)
                    )
                end
              )
            }
        end
    else null end # scalar
;

# Generates a document schema (with options)
#
def generate($opt): #:: α|(OPTIONS) -> SCHEMA
    { "type": type } +
    if isobject then
        if length == 0 then null
        else
            . as $object |
            { "properties": (
                reduce keys_unsorted[] as $name (
                    {};
                    . + {($name): ($object[$name] | generate($opt))}
                )
              )
            } +
            if $opt.required then
            {
                "required": [keys]
            }
            else null end +
            if $opt.object_verbose then
            {
                "additionalProperties": false,
                "minProperties": length,
                "maxProperties": length
            }
            else null end
        end
    elif isarray then
        if length == 0 then null
        else
            { "items": (
                if every(.[] | isscalar) and ([.[] | type] | unique | length) == 1 then
                    { "type": (.[0] | type) }
                elif length == 1 then
                   .[0] | generate($opt) 
                else
                    reduce .[] as $item (
                        [];
                        .[length] = ($item | generate($opt))
                    )
                end
              )
            } +
            if $opt.array_verbose then
            {
                "additionalItems": false,
                "maxItems": length,
                "minItems": 0,
                "uniqueItems": false
            }
            else null end
        end
    elif isnumber then
        if $opt.number_verbose then
        {
            "multipleOf": 1,
            "maximum": 10000,
            "minimum": 1,
            "exclusiveMaximum": false,
            "exclusiveMinimum": false
        }
        else null end
    elif isstring then
        if $opt.string_verbose then
        {
            "minLength": 1,
            "maxLength": 1000,
            "pattern": "^.*$"
        }
        else null end
    else null end # boolean and null
;

# Validates a document against an schema
#
def validate($schema; $root): #:: α|(SCHEMA) -> boolean
    def _validate($schema):
        #
        # Schema keywords
        #
        def k_enum: # keyword enum
            if $schema | has("enum") then
                . as $instance
                | isscalar and ($schema.enum | indices([$instance]) | length) > 0
            else true end
        ;
        def k_type: # keyword type
            if $schema | has("type") then
                type as $t
                | if ($schema["type"] | type) == "string" # string or array
                then $t == $schema["type"] or ($schema["type"] == "integer" and isinteger)
                else some(($schema["type"][] | type) == $t)
                end
            else true end
        ;
        def k_allOf: # keyword allOf
            if $schema | has("allOf") then
                every(_validate($schema.allOf[]))
            else true end
        ;
        def k_anyOf: # keyword anyOf
            if $schema | has("anyOf") then
                some(_validate($schema.anyOf[]))
            else true end
        ;
        def k_oneOf: # keyword oneOf
            if $schema | has("oneOf") then
                [_validate($schema.oneOf[])] == [true]
            else true end
        ;
        def k_not: # keyword not
            if $schema | has("not") then
                try _validate($schema.not) catch false
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
                { # all accepted for now!!!
                    "date-time": true,
                    "email":  true,
                    "hostname": true,
                    "ipv4":  true,
                    "ipv6": true,
                    "uri": true,
                }[$schema.format]//false
            else true end
        ;
#       def c_array: # array constraints
#           if $schema | has("maxItems") then
#               length <= $schema.maxItems
#           else true end
#           and if $schema | has("minItems") then
#               length >= $schema.minItems
#           else true end
#           and if $schema | has("uniqueItems") then
#               ($schema.uniqueItems | not) or length == (unique | length)
#           else true end
#           and if $schema | has("items") then
#               if ($schema.items | isobject) then
#                   every(.[] | _validate($schema.items))
#               else # array: tuple validation
#                   if ($schema.additionalItems == false) and length > ($schema.items | length)
#                   then false
#                   else
#                       every(
#                           range(length) as $i
#                           | if $i in($schema.items)
#                           then .[$i] | _validate($schema.items[$i])
#                           else true end
#                       )
#                   end
#               end
#           else true end
#       ;
        def c_array: # array constraints
            def array_itself:
                if ($schema | has("items") | not) or ($schema.items | isobject)
                    or ($schema.additionalItems == true) or ($schema.additionalItems | isobject)
                then true
                elif $schema.additionalItems == false and $schema.items | isarray
                then length <= ($schema.items | length)
                else false end

            ;
            def array_elements:
                def additional:
                    if ($schema | has("additionalItems") | not)
                        or ($schema.additionalItems == true)
                    then {}
                    elif $schema.additionalItems | isobject
                    then $schema.additionalItems 
                    else null
                    end
                ;
                if ($schema.items | isobject) then
                    every(.[] | _validate($schema.items))
                else
                    additional as $additional
                    | every(
                        range(length) as $i
                        | if $i in($schema.items)
                        then .[$i] | _validate($schema.items[$i])
                        else $additional != null and .[$i] | _validate($additional)
                        end
                    )
                end
            ;
            if $schema | has("maxItems") then
                length <= $schema.maxItems
            else true end
            and if $schema | has("minItems") then
                length >= $schema.minItems
            else true end
            and if $schema | has("uniqueItems") then
                ($schema.uniqueItems | not) or length == (unique | length)
            else true end
            and array_itself
            and array_elements
        ;
        def c_object: # object constraints
            def object_itself:
                if ($schema.additionalProperties == true) or ($schema.additionalProperties | isobject)
                then true
                else # TODO
                end
            ;
            def object_members:
                def additional:
                    if ($schema | has("additionalProperties") | not)
                        or ($schema.additionalProperties == true)
                    then {}
                    elif $schema.additionalProperties | isobject
                    then $schema.additionalProperties 
                    else null
                    end
                ;
                $schema.properties//{} as $p
                | $schema.patternProperties//{} as $pp
                | additional as $additional
                | keys_unsorted as $m
                [   keep_if($m | in($p); $p[$m]),
                    ($pp|keys_unsorted) as $re
                    | keep_if($m | test($re); $pp[$m])
                ] as $s
                | if ($s | length) == 0
                then $additional != null and .[$m] | _validate($additional)
                else .[$m] | some(_validate($s[]))
                end
            ;
            . as $instance
            | if $schema | has("maxProperties") then
                length <= $schema.maxProperties
            else true end
            and if $schema | has("minProperties") then
                length >= $schema.minProperties
            else true end
            and if $schema | has("required") then
                every($instance | has($schema.required[]))
            else true end
            and object_itself
            and object_members
        ;
#       def c_object: # object constraints
#           . as $instance
#           | if $schema | has("maxProperties") then
#               length <= $schema.maxProperties
#           else true end
#           and if $schema | has("minProperties") then
#               length >= $schema.minProperties
#           else true end
#           and if $schema | has("required") then
#               every($instance | has($schema.required[]))
#           else true end
#           and if ($schema | has("additionalProperties") | not)
#                   or ($schema.additionalProperties == true) then
#               if ($schema | has("properties")) and ($schema | has("patternProperties")) then
#                   some(
#                       keys_unsorted[] as $k
#                       | if $k | in($schema.properties)
#                       then $instance[$k] | _validate($schema.properties[$k])
#                       else
#                       end
#                   ) # TODO ???
#               elif $schema | has("properties") then
#                   every(
#                       keys_unsorted[] as $k
#                       | ($k | in($schema.properties) | not)
#                           or ($instance[$k] | _validate($schema.properties[$k]))
#                   )
#               elif $schema | has("patternProperties") then
#                   some(
#                       keys_unsorted[] as $k
#                       | ($schema.patternProperties | keys_unsorted) as $re
#                       | if $k|test($re)
#                       then
#                           $instance[$k] | _validate($schema.patternProperties[$re])
#                       else false end
#                   )
#               else true end
#           else true end
#           and if $schema.additionalProperties == false then
#               if ($schema | has("properties")) and ($schema | has("patternProperties")) then
#                   true    # TODO
#               elif $schema | has("properties") then
#                   every(
#                       keys_unsorted[] as $k
#                       | ($k | in($schema.properties))
#                           and ($instance[$k] | _validate($schema.properties[$k]))
#                   )
#               elif $schema | has("patternProperties") then
#                   true    # TODO
#               else length == 0 end
#           else true end
#           and if $schema.additionalProperties | isobject then
#               if ($schema | has("properties")) and ($schema | has("patternProperties")) then
#                   true    # TODO
#               elif $schema | has("properties") then
#                   true    # TODO
#               elif $schema | has("patternProperties") then
#                   true    # TODO
#               else true end
#           else true end
#       ;
        #
        # Validate
        #
        def check(constraint):
            constraint or ({ instance: ., schema: $schema } | error)
        ;
        if $schema == null or $schema == {}
        then true
        else
            check(k_type)  and
            check(k_enum)  and
            check(k_allOf) and
            check(k_anyOf) and
            check(k_oneOf) and
            check(k_not)   and
            if isnumber then check(c_number)
            elif isstring then check(c_string)
            elif isarray then check(c_array)
            elif isobject then check(c_object)
            else true end # null, boolean
        end # empty or null schema
    ;
    #
    _validate($schema)
;

# Simple boolean validation
#
def valid($schema): #:: α|(SCHEMA) -> boolean
    . as $root
    | try validate($schema; $root)
      catch false
;

# vim:ai:sw=4:ts=4:et:syntax=jq
