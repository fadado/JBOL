module {
    name: "math/chance",
    description: "Basic pseudo-random generators",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

# TODO: adapt to future jq builtins (expected in jq 1.6)

########################################################################
# Random
########################################################################

# Advances a seed producing random bits and a new seed.
#
def _NXTGEN: #:: number| => [number,number]
    . as $seed
    | (((214013 * $seed) + 2531011) % 2147483648) as $state # mod 2^31
    | ($state / 65536 | trunc) as $value  # >> 16
    | [ $value, $state ]
;

# Makes a seed from a starting value.
#
def randomize($seed): #:: (number) => number
    $seed|_NXTGEN[1]
;
def randomize: #:: => number
    randomize(now)
;

# Generates a stream of random 2^15 values.
#
def rand($seed): #:: (number) => *number
    unfold(_NXTGEN; $seed)
;

# Generates a stream of random [0..1) values.
#
def rnd($seed): #:: (number) => *number
    unfold(_NXTGEN; $seed)
    | . / 32768
;

# Generates a random [0..n) stream.
#
def random($n; $seed): #:: (number;number) => *number
    unfold(_NXTGEN; $seed)
    | .%($n)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
