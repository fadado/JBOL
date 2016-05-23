# data/hardware.json == (j2y data/hardware.json | y2j)

cd $(dirname $0)

# Conversions
Y2J=../bin/y2j
J2Y=../bin/j2y

# Slurp two files
jq  --slurp --raw-output \
    'if .[0] == .[1]
        then empty
        else "Failed conversion JSON <==> YAML"
        end' \
    data/hardware.json \
    <(${J2Y} data/hardware.json | ${Y2J})

exit

# vim:ai:sw=4:ts=4:et:syntax=sh
