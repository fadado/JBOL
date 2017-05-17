module {
    name: "schema",
    description: "JSON schema generation and validation",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";

import "fadado.github.io/generator" as generator;
import "fadado.github.io/string/url" as url;
import "fadado.github.io/string/regexp" as re;

# Generates a simple document schema
#
# SCHEMA: a JSON schema document
def generate: #:: a| => SCHEMA
    { "type": type }
    + if isobject then
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
                if every(.[] | isscalar)
                   and ([.[] | type] | unique | length) == 1
                then
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
# OPTIONS: an object of runtime options
# SCHEMA: a JSON schema document
def generate($options): #:: a|(OPTIONS) => SCHEMA
    { "type": type }
    + if isobject then
        if length == 0 then null
        else
            . as $object |
            { "properties": (
                reduce keys_unsorted[] as $name (
                    {};
                    . + {($name): ($object[$name] | generate($options))}
                )
              )
            }
            + if $options.required then
                {
                    "required": [keys]
                }
            else null end
            + if $options.object_verbose then
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
                if every(.[] | isscalar)
                   and ([.[] | type] | unique | length) == 1
                then
                    { "type": (.[0] | type) }
                elif length == 1 then
                   .[0] | generate($options)
                else
                    reduce .[] as $item (
                        [];
                        .[length] = ($item | generate($options))
                    )
                end
              )
            }
            + if $options.array_verbose then
                {
                    "additionalItems": false,
                    "maxItems": length,
                    "minItems": 0,
                    "uniqueItems": false
                }
            else null end
        end
    elif isnumber then
        if $options.number_verbose then
            {
                "multipleOf": 1,
                "maximum": 10000,
                "minimum": 1,
                "exclusiveMaximum": false,
                "exclusiveMinimum": false
            }
        else null end
    elif isstring then
        if $options.string_verbose then
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
# SCHEMA: a JSON schema document
def validate($schema; $fatal): #:: a|(SCHEMA;boolean) => boolean
    def pointer($s):
        def unescape:
            re::gsub("~1"; "/") | re::gsub("~0"; "~")
            | url::decode
        ;
        if $s|startswith("#")|not
        then error("Only supported pointers in current document: \($s)")
        elif $s == "#"
        then $schema # root
        elif $s|startswith("#/")|not
        then error("Only supported absolute pointers")
        else
            $schema
            | [($s[2:] / "/")[] | unescape as $x | try tonumber catch $x] as $p
            | getpath($p)
            | when(isnull; error("Cannot dereference path: \($p)"))
        end
    ;
    def _validate($schema; $fatal):
        #
        # Schema keywords
        #
        def k_enum: # keyword enum
            rule($schema | has("enum");
                . as $instance
                | ($schema.enum | indices([$instance]) | length) > 0)
        ;
        def k_type: # keyword type
            def cmp($t; $r):
                $t == $r
                or ($t == "number" and $r == "integer" and isinteger)
            ;
            rule($schema | has("type");
                type as $t
                | if isstring($schema["type"]) # string or array
                  then cmp($t; $schema["type"])
                  else some(cmp($t; $schema["type"][])) end)
        ;
        def k_allOf: # keyword allOf
            rule($schema | has("allOf");
                every(_validate($schema.allOf[]; $fatal)))
        ;
        def k_anyOf: # keyword anyOf
            rule($schema | has("anyOf");
                some(_validate($schema.anyOf[]; false)))
        ;
        def k_oneOf: # keyword oneOf
            rule($schema | has("oneOf");
                generator::singleton(_validate($schema.oneOf[]; false) | select(.)))
        ;
        def k_dependencies: # keyword dependencies
            rule(($schema | has("dependencies")) and isobject;
                . as $instance
                | every(
                    $schema.dependencies | keys_unsorted[]
                    | rule(in($instance);
                        $schema.dependencies[.] as $d
                        | if isarray($d)
                          then every($d[] | in($instance))
                          else $instance | _validate($d; $fatal) end)))
        ;
        #
        # Type constraints
        #
        def c_number: # number constraints
            rule($schema | has("multipleOf");
                . / $schema.multipleOf | isinteger)
            and rule($schema | has("maximum");
                if $schema.exclusiveMaximum
                then . < $schema.maximum
                else . <= $schema.maximum end)
            and rule($schema | has("minimum");
                if $schema.exclusiveMinimum
                then . > $schema.minimum
                else . >= $schema.minimum end)
        ;
        def c_string: # string constraints
            rule($schema | has("maxLength");
                length <= $schema.maxLength)
            and rule($schema | has("minLength");
                length >= $schema.minLength)
            and rule($schema | has("pattern");
                test($schema.pattern))
            and rule($schema | has("format");
                ({  "date-time": "^[0-9]{4}-(?:0[0-9]|1[0-2])-[0-9]{2}[tT ][0-9]{2}:[0-9]{2}:[0-9]{2}(?:[.][0-9]+)?(?:[zZ]|[+-][0-9]{2}:[0-9]{2})$",
                    "email": "^[^ \t\r\n]+@[^ \t\r\n]+$",
                    "hostname": "^(?:[0-9A-Za-z]|[0-9A-Za-z][0-9A-Za-z-]{0,61}[0-9A-Za-z])(?:[.](?:[0-9A-Za-z]|[0-9A-Za-z][0-9A-Za-z-]{0,61}[0-9A-Za-z]))*$",
                    "ipv4": "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)[.]){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
                    "uri": "^[A-Za-z][0-9A-Za-z+-.]*:[^ \t\r\n]*"
                }[$schema.format]
                    // "^.") as $re # any non empty string as default
                | test($re))
        ;
        def c_array: # array constraints
            def valid_array:
                ($schema | has("items")|not)
                or ($schema.items | isobject)
                or ($schema | has("additionalItems")|not)
                or ($schema.additionalItems == true)
                or ($schema.additionalItems | isobject)
                or ($schema.additionalItems == false and ($schema.items | isarray))
                    and length <= ($schema.items | length)
            ;
            def valid_elements:
                def additionalItems:
                    if ($schema | has("additionalItems")|not)
                        or $schema.additionalItems == true
                    then {}
                    elif $schema.additionalItems | isobject
                    then $schema.additionalItems
                    else null end
                ;
                ($schema.items//{}) as $items
                | if ($items | isobject) then
                    every(.[] | _validate($items; $fatal))
                else # isarray
                    additionalItems as $additional
                    | every(
                        range(length) as $i
                        | if $i|in($items) # $i < ($items|length)
                          then .[$i] | _validate($items[$i]; $fatal)
                          else $additional != null
                               and (.[$i] | _validate($additional; $fatal)) end
                      )
                end
            ;
            valid_array
            and rule($schema | has("maxItems");
                length <= $schema.maxItems)
            and rule($schema | has("minItems");
                length >= $schema.minItems)
            and rule($schema | has("uniqueItems");
                ($schema.uniqueItems|not)
                or length == (unique | length))
            and valid_elements
        ;
        def c_object: # object constraints
            def valid_object:
                ($schema | has("additionalProperties")|not)
                or $schema.additionalProperties == true
                or ($schema.additionalProperties | isobject)
                or $schema.additionalProperties == false
                and ($schema.properties//{}) as $p
                    | ($schema.patternProperties//{}) as $pp
                    | [ keys_unsorted[]
                        | select(in($p)|not)
                        | select(every(test($pp | keys_unsorted[])|not)) ]
                    | length == 0
            ;
            def valid_members:
                def additionalProperties:
                    if ($schema | has("additionalProperties")|not)
                        or $schema.additionalProperties == true
                    then {}
                    elif $schema.additionalProperties | isobject
                    then $schema.additionalProperties
                    else null end
                ;
                additionalProperties as $additional
                | ($schema.properties//{}) as $p
                | ($schema.patternProperties//{}) as $pp
                | every(
                    keys_unsorted[] as $m
                    | [ keep($m | in($p); $p[$m])
                        , (($pp | keys_unsorted[]) as $re
                            | keep($m | test($re); $pp[$re]))
                      ] as $s
                    | if ($s | length) > 0
                      then .[$m] | every(_validate($s[]; $fatal))
                      else $additional != null
                           and (.[$m] | _validate($additional; $fatal)) end
                  )
            ;
            valid_object
            and rule($schema | has("maxProperties");
                length <= $schema.maxProperties)
            and rule($schema | has("minProperties");
                length >= $schema.minProperties)
            and rule($schema | has("required");
                every(has($schema.required[])))
            and valid_members
        ;
        #
        # Validate
        #
        def check(constraint):
            constraint
            or $fatal and ({ instance: ., schema: $schema } | error)
        ;
        $schema == null
        or $schema == {}
        or if isobject and has("$ref") # when validating schemas!
        then .["$ref"] | isstring
        elif $schema | has("$ref")
        then _validate(pointer($schema["$ref"]); $fatal)
        elif $schema | has("not")
        then
            _validate($schema | del(.not); $fatal)
            and (_validate($schema.not; $fatal)|not)
        else
            check(k_type)
            and check(k_enum)
            and check(k_allOf)
            and check(k_anyOf)
            and check(k_oneOf)
            and check(k_dependencies)
            and if isnumber then check(c_number)
            elif isstring   then check(c_string)
            elif isarray    then check(c_array)
            elif isobject   then check(c_object)
            else isnull or isboolean end
        end
    ;
    #
    _validate($schema; $fatal)
;

# Validates a document against an schema
#
# SCHEMA: a JSON schema document
def validate($schema): #:: a|(SCHEMA) => boolean
    validate($schema; true)
;

# Validates a document without signaling errors
#
# SCHEMA: a JSON schema document
def valid($schema): #:: a|(SCHEMA) => boolean
    validate($schema; false)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
