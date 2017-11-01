module {
    name: "music/pitch",
    description: "Pitch functions",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/math";

########################################################################
# Pitch representation (simple number: 0..127)

def pitch_invert($interval): #:: number|(number) => number
#   . as $pitch
    . + $interval
;

def pitch_transpose($interval): #:: number|(number) => number
#   . as $pitch
    $interval - .
;

def pitch_format: #:: number| => string
#   . as $pitch
	["C","Cs","D","Ds","E","F","Fs","G","Gs","A","As","B"] as $names
    | div(.; 12) as $octave
    | (. % 12) as $note
    | "\($names[$note])\($octave)"

;

# vim:ai:sw=4:ts=4:et:syntax=jq
