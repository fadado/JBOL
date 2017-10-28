module {
    name: "math",
    description: "Miscelaneous mathematical functions",
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

def invert($interval): #:: number|(number) => number
    #. as $pitch
    mod(. + $interval; 128)
;

def transpose($interval): #:: number|(number) => number
    #. as $pitch
    mod($interval - .; 128)
;

def format: #:: number| => string
    #. as $pitch
	["C","Cs","D","Ds","E","F","Fs","G","Gs","A","As","B"] as $names
    | (div(.; 12) - 2) as $octave   # MIDI octave
    | mod(.; 12) as $note
    | "\($names[$note])\($octave)"

;

# vim:ai:sw=4:ts=4:et:syntax=jq
