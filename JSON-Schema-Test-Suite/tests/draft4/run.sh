#!/bin/bash

declare -r JBOL='/usr/local/share/jbol'

for t in *.json
do
    #echo $t 1>&2
    jq -L $JBOL \
        --arg TEST $t       \
        --from-file run.jq  \
        --raw-output        \
        $t
    echo
done | grep .

# vim:syntax=sh:ai:sw=4:ts=4:et
