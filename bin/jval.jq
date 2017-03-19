# Called from the `jval` Bash script

import "fadado.github.io/schema" as schema;

# SCHEMA parameter is provided by the calling script
$SCHEMA[0] as $schema |

# Require '$schema' property in root schema
if ($schema | type) != "object" or ($schema | has("$schema") | not)
then
    "Error: expected '$schema' property in schema root object"
else
    try (schema::validate($schema) | "") # no output if ok
    catch "Validation error; instance: \(.instance); schema: \(.schema)"
end

# vim:ai:sw=4:ts=4:et:syntax=jq
