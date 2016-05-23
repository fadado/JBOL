# jq q JSON == yq q YAML

cd $(dirname $0)

# Conversions
J2Y=../bin/j2y
YQ=../bin/yq

# Same result
diff <(jq --sort-keys '.store.book[1]' data/store.json | ${J2Y}) \
     <(${YQ} --sort-keys '.store.book[1]' data/store.yaml)

exit

# vim:ai:sw=4:ts=4:et:syntax=sh
