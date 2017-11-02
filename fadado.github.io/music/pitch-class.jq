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
# pitch: 0..127 (MIDI pitch)
#        [0-9te] (pitch-class representative)
#        [A-G][#b]?([0-9]|10) (note name with octave)
#   . as $pitch
    if type == "number" then
        math::mod(.; 12)    # . is a pitch in the range 0..127
    elif type == "string" then
        if test("^[0-9te]$")# representative
        then
            if .=="t"       # ten
            then 10
            elif .=="e"     # eleven
            then 11
            else tonumber   # 0..9
            end
        elif test("^([A-G])([#b])?([0-9]|10)$") # note name with octave
        then
            {"C":0,"D":2,"E":4,"F":5,"G":7,"A":9,"B":11}[.[0:1]] as $n
            | .[1:2] as $a
            | if $a=="#"
              then math::mod($n+1; 12) # sharp
              elif $a=="b"
              then math::mod($n-1; 12) # flat
              else $n end
        else
            "Malformed pitch: \(.)" | error
        end
    else type | "Type error: expected number or string, not \(.)" | error
    end
;
def pitch_class($pitch): #::(a) => number
    $pitch | pitch_class
;

# Inverts a pitch-class
def invert($interval): #:: number|(number) => number
# interval: -11..0..11
#   . as $pitch_class
    math::mod(-. + $interval; 12)
;
def invert: #:: number| => number
#   . as $pitch_class
    invert(0)
;

# Trasposes a pitch-class
def transpose($interval): #:: number|(number) => number
# interval: -11..0..11
#   . as $pitch_class
    math::mod(. + $interval; 12)
;

# Produces the note name
def name: #:: number| => number
#   . as $pitch_class
    ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"][.]
;

# Format a pitch-class as a string
def format: #:: number| => string
#   . as $pitch_class
    ["0","1","2","3","4","5","6","7","8","9","t","e"][.]
;

# pc ∈ pcs
def member($pcset): #:: number|([number]) => boolean
    . as $pitch_class
    | $pcset | contains([$pitch_class])
;

########################################################################
# Intervals

# Produces the chromatic interval (0..11) between two pitch-classes
def chromatic_interval($pclass): #:: number|(number) => number
#   . as $pitch_class
    math::mod($pclass - .; 12)
;

# Produces the interval-class (0..6) for specific interval
def interval_class: #:: number| => number
#   . as $chromatic_interval
    when(. > 6; 12 - .) # > tritone?
;

# Produces the interval-class (0..6) between two pitch-classes
def interval_class($pclass): #:: number|(number) => number
#   . as $pitch_class
    chromatic_interval($pclass) | interval_class
;

# vim:ai:sw=4:ts=4:et:syntax=jq
