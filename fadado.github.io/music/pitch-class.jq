module {
    name: "music/pitch-class",
    description: "Pitch-class functions",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/math" as math;

########################################################################
# pitch-class: (0..11)

# Produces the pitch-class corresponding to a pitch
def pitch_class: #:: <number^string>| => number
#   . as $pitch
    if type == "number" then
        math::mod(.; 12)    # pitch: 0..128
    elif type == "string" then
        if .=="t" or .=="T" or .=="a" or .=="A"     # then
        then 10
        elif .=="e" or .=="E" or .=="b" or .=="B"   # eleven
        then 11
        else tonumber       # 0..9
        end
    else type | "Type error: expected number or string, not \(.)" | error
    end
;
def pitch_class($pitch): #::(a) => number
    $pitch | pitch_class
;

# Inverts a pitch-class
def invert($interval): #:: number|(number) => number
#   . as $pitch_class
    math::mod(0-. + $interval; 12)
;

# Trasposes a pitch-class
def transpose($interval): #:: number|(number) => number
#   . as $pitch_class
    math::mod(. + $interval; 12)
;

# Produces the note name
def name: #:: number| => number
#   . as $pitch_class
    ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"][.]
;

# Format a pitch-class as a string
def representative: #:: number| => string
#   . as $pitch_class
    ["0","1","2","3","4","5","6","7","8","9","t","e"][.]
;

# pc ∈ pcs
def member($pcset): #:: number|([number]) => number
#   . as $pitch_class
    [.] | inside($pcset)
;

########################################################################
# Intervals

# Produces the pitch-class interval (0..11) between two pitch-classes
def interval($pc): #:: number|(number) => number
#   . as $pitch_class
    math::mod($pc - .; 12)
;

# Produces the interval-class (0..6) for a pitch-class interval
def interval_class: #:: number| => number
#   . as $interval
    when(. > 6; # > tritone?
        12 - .)
;

# Produces the interval-class (0..6) between two pitch-classes
def interval_class($pc): #:: number|(number) => number
    interval($pc) | interval_class
;

# vim:ai:sw=4:ts=4:et:syntax=jq
