# Called from the `jval` Bash script

import "fadado.github.io/json/schema" as schema;

def report($schema):
    if (.data | schema::valid($schema)) == .valid
    then empty
    else $TEST+": "+.description
    end
;

.[]
| .schema as $schema
| .tests[] | report($schema)

# vim:ai:sw=4:ts=4:et:syntax=jq
