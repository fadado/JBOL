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
# OPTIONS: an object of runtime options
# SCHEMA: a JSON schema document
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
# SCHEMA: a JSON schema document
def validate($schema; $fatal): #:: α|(SCHEMA;boolean) -> boolean
    def rule(a; c): if a then c else true;
    def pointer($s):
        if $s | startswith("#") | not
        then error("Only supported pointers in current document")
        elif $s == "#"
        then $schema # root
        elif $s | startswith("#/") | not
        then error("Only supported absolute pointers")
        else
            $schema
            | getpath($s[2:] / "/")
            | when(isnull; error("Cannot dereference pointer"))
        end
    ;
    def _validate($schema; $fatal):
        #
        # Schema keywords
        #
        def k_enum: # keyword enum
            rule($schema | has("enum");
                . as $instance
                | isscalar and ($schema.enum | indices([$instance]) | length) > 0
            )
        ;
        def k_type: # keyword type
            if $schema | has("type") then
                type as $t
                | if ($schema["type"] | type) == "string" # string or array
                then $t == $schema["type"] or ($t == "number" and $schema["type"] == "integer" and isinteger)
                else some(($schema["type"][] | type) == $t)
                end
            else true end
        ;
        def k_allOf: # keyword allOf
            if $schema | has("allOf") then
                every(_validate($schema.allOf[]; $fatal))
            else true end
        ;
        def k_anyOf: # keyword anyOf
            if $schema | has("anyOf") then
                some(_validate($schema.anyOf[]; false))
            else true end
        ;
        def k_oneOf: # keyword oneOf
            if $schema | has("oneOf") then
                [_validate($schema.oneOf[]; false)] == [true]
            else true end
        ;
        def k_dependencies: # keyword dependencies
            if $schema | has("dependencies") then
                . as $instance
                | every(
                    $schema.dependencies
                    | keys_unsorted[]
                    | if in($instance)
                    then
                        $schema.dependencies[.] as $d
                        | if $d | isarray
                        then every($d[] | in($instance))
                        else $instance | _validate($d; $fatal)
                        end
                    else true end
                  )
            else true end
        ;
        def k_dependencies: # keyword dependencies
            if $schema | has("dependencies") then
                . as $instance
                | every(
                    $schema.dependencies
                    | keys_unsorted[]
                    | if in($instance)
                    then
                        $schema.dependencies[.] as $d
                        | if $d | isarray
                        then every($d[] | in($instance))
                        else $instance | _validate($d; $fatal)
                        end
                    else true end
                  )
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
                {   "date-time": "[0-9]",   # one digit at least
                    "email": "^.+@.+$",     # one @ inside text
                    "hostname": "[A-Za-z]", # one letter at least
                    "ipv4": "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", # 4 digits triples
                    "ipv6": "[0-9]",        # one digit at least
                    "uri": "^[a-zA-Z]:",    # required schema prefix
                    "uriref": "^."          # non empty string
                }[$schema.format]//"^." as $re # any non empty string as default
                | test($re)
            else true end
        ;
        def c_array: # array constraints
            def valid_array:
                ($schema | has("items") | not)
                or ($schema.items | isobject)
                or ($schema | has("additionalItems") | not)
                or ($schema.additionalItems == true)
                or ($schema.additionalItems | isobject)
                or if $schema.additionalItems == false and ($schema.items | isarray)
                then length <= ($schema.items | length)
                else false end
            ;
            def valid_elements:
                def additionalItems:
                    if ($schema | has("additionalItems") | not)
                        or ($schema.additionalItems == true)
                    then {}
                    elif $schema.additionalItems | isobject
                    then $schema.additionalItems 
                    else false end
                ;
                if ($schema.items | isobject) then
                    every(.[] | _validate($schema.items; $fatal))
                else # isarray
                    additionalItems as $additional
                    | every(
                        range(length) as $i
                        | if $i | in($schema.items) # $i < ($schema.items|length)
                        then .[$i] | _validate($schema.items[$i]; $fatal)
                        elif $additional != false
                        then .[$i] | _validate($additional; $fatal)
                        else false end
                      )
                end
            ;
            valid_array
            and if $schema | has("maxItems") then
                length <= $schema.maxItems
            else true end
            and if $schema | has("minItems") then
                length >= $schema.minItems
            else true end
            and if $schema | has("uniqueItems") then
                ($schema.uniqueItems | not) or length == (unique | length)
            else true end
            and valid_elements
        ;
        def c_object: # object constraints
            def valid_object:
                ($schema | has("additionalProperties") | not)
                or ($schema.additionalProperties == true)
                or ($schema.additionalProperties | isobject)
                or if $schema.additionalProperties == false
                then
                    ($schema.properties//{}) as $p
                    | ($schema.patternProperties//{}) as $pp
                    | [ keys_unsorted[]
                        | select(in($p) | not)
                        | select(every(test($pp | keys_unsorted[]) | not))
                      ]
                    | length == 0
                else false end
            ;
            def valid_members:
                def additionalProperties:
                    if ($schema | has("additionalProperties") | not)
                        or ($schema.additionalProperties == true)
                    then {}
                    elif $schema.additionalProperties | isobject
                    then $schema.additionalProperties 
                    else false
                    end
                ;
                additionalProperties as $additional
                | ($schema.properties//{}) as $p
                | ($schema.patternProperties//{}) as $pp
                | every(
                    keys_unsorted[] as $m
                    | [ keep_if($m | in($p); $p[$m]),
                        (($pp | keys_unsorted[]) as $re
                            | keep_if($m | test($re); $pp[$re]))
                    ] as $s
                    | if ($s | length) > 0
                    then .[$m] | every(_validate($s[]; $fatal))
                    elif $additional != false
                    then .[$m] | _validate($additional; $fatal)
                    else false end
                  )
            ;
            valid_object
            and if $schema | has("maxProperties") then
                length <= $schema.maxProperties
            else true end
            and if $schema | has("minProperties") then
                length >= $schema.minProperties
            else true end
            and if $schema | has("required") then
                every(has($schema.required[]))
            else true end
            and valid_members
        ;
        #
        # Validate
        #
        def check(constraint):
            constraint 
            or if $fatal
            then { instance: ., schema: $schema } | error
            else false end
        ;
        if $schema == null or $schema == {}
        then true
        elif isobject and has("$ref") # when validating schemas!
        then .["$ref"] | isstring
        elif $schema | has("$ref")
        then _validate(pointer($schema["$ref"]); $fatal)
        elif $schema | has("not")
        then
            _validate($schema | del(.not); $fatal)
            and (_validate($schema.not; $fatal) | not)
        else
            check(k_type)  and
            check(k_enum)  and
            check(k_allOf) and
            check(k_anyOf) and
            check(k_oneOf) and
            check(k_dependencies) and
            if isnumber     then check(c_number)
            elif isstring   then check(c_string)
            elif isarray    then check(c_array)
            elif isobject   then check(c_object)
            else true end # null, boolean
        end
    ;
    #
    _validate($schema; $fatal)
;

# SCHEMA: a JSON schema document
def validate($schema): #:: α|(SCHEMA) -> boolean
    validate($schema; true)
;

# SCHEMA: a JSON schema document
def valid($schema): #:: α|(SCHEMA) -> boolean
    validate($schema; false)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
