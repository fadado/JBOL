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
    | try (schema::validate($schema; $root) | "")
      catch "Validation error. Instance: \(.instance); Schema: \(.schema)"
end


# vim:ai:sw=4:ts=4:et:syntax=jq
