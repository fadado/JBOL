#
# Validates an instance document against a JSON schema.
#
include "fadado.github.io/prelude";
include "fadado.github.io/types";
import "fadado.github.io/schema" as schema;

# Main
#
$SCHEMA[0] as $schema
| if $schema | has("$schema") | not
then
    "Expected '$schema' property in root instance"
else
    . as $root
    | try
        if schema::valid($schema) | not
        then "Validation error"
        else "" end
      catch "Error: \(.)"
end


# vim:ai:sw=4:ts=4:et:syntax=jq
