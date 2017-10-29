module {
    name: "music/pclass",
    description: "Pitch-class functions",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/math";

########################################################################
# pitch class (0..11)

# Produces the pitch-class corresponding to a pitch.
def pitch_class: #:: number| => number
#   . as $pitch
    mod(.; 12)
;
def pitch_class($pitch): #::(number) => number
    mod($pitch; 12)
;

# Produces an inverted pitch-class.
def pc_invert($interval): #:: number|(number) => number
#   . as $pitch_class
    mod(-. + $interval; 12)
;

# Produces a trasposed pitch-class.
def pc_transpose($interval): #:: number|(number) => number
#   . as $pitch_class
    mod(. + $interval; 12)
;

# Tests pitch-class membership in pitch-class sets.
def pc_in($pcset): #:: number|([number]) => number
#   . as $pitch_class
    [.] | inside($pcset)
;

# Format a pitch-class as a string.
def pc_tostring: #:: number| => string
#   . as $pitch_class
    if . == 10
    then "t"
    elif . == 11
    then "e"
    else tostring
    end
;

# Scan a pitch-class string.
def pc_tonumber: #:: string| => number
#   . as $string
    if . == "t"
    then 10
    elif . == "e"
    then 11
    else tonumber
    end
;

########################################################################
# Intervals

# Produces the pitch class interval (0..11) between two pitch-classes
def pc_interval($pc): #:: number|(number) => number
#   . as $pitch_class
    mod($pc - .; 12)
;

# Produces the interval class (0..6) for a pitch class interval
def interval_class: #:: number| => number
#   . as $pc_interval
    when(. > 6; # > tritone?
        12 - .)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
