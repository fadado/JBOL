module {
    name: "string",
    description: "URL string operations",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

import "fadado.github.io/math" as math;

# Inspired in https://www.rosettacode.org/wiki/URL_decoding#jq
def decode: #:: string| => string
    .  as $in
    | length as $length
    | {i: 0, answer: ""}
    | until (.i >= $length;
        if $in[.i:.i+1] == "%"
        then
            .answer += ([$in[.i+1:.i+3] | math::frombase(16)] | implode)
            | .i += 3
        else
            .answer += $in[.i:.i+1]
            | .i += 1
        end
      )
    | .answer
;

# vim:ai:sw=4:ts=4:et:syntax=jq
