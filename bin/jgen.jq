#
# Generates JSON schema for an instance document
#

import "fadado.github.io/schema" as schema;

# Metadata header
def meta:
    {
        "$schema": "http://json-schema.org/draft-04/schema#",
        "title": "Schema title",
        "description": "Schema description"
    }
;

# Runtime options
def options:
{ # boolean options, all defined in the calling script
    array_verbose:  $opt_array_verbose,
    number_verbose: $opt_number_verbose,
    object_verbose: $opt_object_verbose,
    required:       $opt_required,
    string_verbose: $opt_string_verbose
};

# Main
meta + schema::generate(options)

# vim:ai:sw=4:ts=4:et:syntax=jq
