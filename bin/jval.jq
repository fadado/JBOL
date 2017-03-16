#
# Validates an instance document against a JSON schema.
#

import "fadado.github.io/schema" as schema;

# Main
#
$SCHEMA[0] as $schema
| if $schema | has("$schema") | not
then
    "Expected '$schema' property in schema root object"
else
    try (schema::validate($schema) | "")
    catch "Validation error; instance: \(.instance); schema: \(.schema)"
end


# vim:ai:sw=4:ts=4:et:syntax=jq
