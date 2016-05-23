# yq q YAML == s

cd $(dirname $0)

# Conversions
YQ=../bin/yq

# Extract string
if [[ $(${YQ} -J -r .store.bicycle.color data/store.yaml) == red ]]
then
    : # ok
else
    echo 1>&2 'Error using yq'
fi

exit

# vim:ai:sw=4:ts=4:et:syntax=sh
