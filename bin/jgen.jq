# Called from the `jgen` Bash script

import "fadado.github.io/schema" as schema;

# Metadata header
def metadata:
    {
        "$schema": "http://json-schema.org/draft-04/schema#",
        "title": "Schema title",
        "description": "Schema description"
    }
;

# Runtime options, all defined in the calling script
def options:
    {
        array_verbose:  $opt_array_verbose,
        number_verbose: $opt_number_verbose,
        object_verbose: $opt_object_verbose,
        required:       $opt_required,
        string_verbose: $opt_string_verbose
    }
;

# For each input JSON document generates the corresponding JSON schema
metadata + schema::generate(options)

# vim:ai:sw=4:ts=4:et:syntax=jq
