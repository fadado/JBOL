# data/hardware.json == (j2y data/hardware.json | y2j)

cd $(dirname $0)

# Conversions
Y2J=../bin/y2j
J2Y=../bin/j2y

# Slurp two files into variable
jq --null-input --raw-output \
    --slurpfile j1 data/hardware.json \
    --slurpfile j2 <(${J2Y} data/hardware.json | ${Y2J}) \
    'if $j1 == $j2
        then empty
        else "Failed conversion JSON <==> YAML"
        end'

exit

# vim:ai:sw=4:ts=4:et:syntax=sh

