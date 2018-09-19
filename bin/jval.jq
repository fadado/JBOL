# Called from the `jval` Bash script

include "fadado.github.io/types";
import "fadado.github.io/json/schema" as schema;

# SCHEMA parameter is provided by the calling script
$SCHEMA[0] as $schema |

# Require '$schema' property in root schema
if ($schema | isobject) and ($schema | has("$schema"))
then
    try (schema::validate($schema) | "") # no output if ok
    catch "Validation error (\(input_filename):\(input_line_number)); instance: \(.instance); schema: \(.schema)"
else
    "Error: expected '$schema' property in schema root object: \(.)"
end

# vim:ai:sw=4:ts=4:et:syntax=jq
