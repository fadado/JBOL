#
# Generates JSON schema for an instance document
#

import "fadado.github.io/schema" as schema;

# Main
#
def meta:
    {
        "$schema": "http://json-schema.org/schema#",
        "title": "Schema title",
        "description": "Schema description"
    }
;

def options:
{
    array_verbose: $opt_array_verbose,
    number_verbose: $opt_number_verbose,
    object_verbose: $opt_object_verbose,
    required: $opt_required,
    string_verbose: $opt_string_verbose
};

options as $opt
| meta + schema::generate($opt)

# vim:ai:sw=4:ts=4:et:syntax=jq
