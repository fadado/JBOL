#!/usr/local/bin/jq -f

include "fadado.github.io/prelude";
include "fadado.github.io/types";

# Generates a document schema
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
            } +
            if $opt_required then
            {
                "required": [keys]
            }
            else null end +
            if $opt_object_verbose then
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
                if every(.[]|isscalar) and ([.[]|type]|unique|length) == 1 then
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
            } +
            if $opt_array_verbose then
            {
                "additionalItems": false,
                "maxItems": length,
                "minItems": 0,
                "uniqueItems": false
            }
            else null end
        end
    elif isnumber then
        if $opt_number_verbose then
        {
            "multipleOf": 1,
            "maximum": 10000,
            "minimum": 1,
            "exclusiveMaximum": false,
            "exclusiveMinimum": false
        }
        else null end
    elif isstring then
        if $opt_string_verbose then
        {
            "minLength": 1,
            "maxLength": 1000,
            "pattern": "^.*$"
        }
        else null end
    else null end # boolean and null
;

# Main
#
{
    "$schema": "http://json-schema.org/schema#",
    "title": "Schema title",
    "description": "Schema description"
} + schema

# vim:ai:sw=4:ts=4:et:syntax=jq
