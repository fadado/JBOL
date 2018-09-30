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
def _NXTGEN: #:: number => [number,number]
    . as $previous_seed
    | (((214013 * $previous_seed) + 2531011) % 2147483648) as $seed # mod 2^31
    | ($seed / 65536 | trunc) as $value  # >> 16
    | [ $value, $seed ]
;

# Makes a seed from a starting value.
#
def randomize($seed): #:: (number) => number
    $seed | _NXTGEN[1]
;
def randomize: #:: => number
    now | _NXTGEN[1]
;

# Generates a stream of random 2^15 values.
#
def rand($seed): #:: (number) => *number
    $seed|unfold(_NXTGEN)
;

# Generates a stream of random [0..1) values.
#
def rnd($seed): #:: (number) => *number
    $seed|unfold(_NXTGEN)
    | . / 32768
;

# Generates a random [0..n) stream.
#
def random($n; $seed): #:: (number;number) => *number
    $seed|unfold(_NXTGEN)
    | .%($n)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
