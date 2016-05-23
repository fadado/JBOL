# Generate language from alphabet

cd $(dirname $0)

trap "rm -f /tmp/star[12].tmp$$" EXIT

./star.jq --arg alphabet '01' --argjson ordered true  \
    | head --lines 20 >/tmp/star1.tmp$$

./star.jq --arg alphabet '01' --argjson ordered false \
    | head --lines 20 >/tmp/star2.tmp$$

echo '=======+==========='
echo 'ORDERED|NOT ORDERED'
echo '=======+==========='

paste /tmp/star[12].tmp$$

exit

# vim:ai:sw=4:ts=4:et:syntax=sh
