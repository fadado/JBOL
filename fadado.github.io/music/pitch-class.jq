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
import "fadado.github.io/music/pitch" as pitch;

########################################################################
# pitch-class: 0..11

# Produces the pitch-class corresponding to a pitch
def new: #:: <number^string>| => number
#   . as $x
    if type == "number" then
        # . must be a pitch in the range 0..127
        pitch::new % 12
    elif type == "string" then
        if test("^[0-9te]$")    # representative
        then
            if .=="t"           # ten
            then 10
            elif .=="e"         # eleven
            then 11
            else tonumber       # 0..9
            end
        else
            # . must be a note name with octave
            pitch::new % 12
        end
    else type | "Type error: expected number or string, not \(.)" | error
    end
;
def new($x): #::(<number^string>) => number
    $x | new
;

# Format a pitch-class as a string
def format: #:: number| => string
#   . as $pitch_class
    ["0","1","2","3","4","5","6","7","8","9","t","e"][.]
;

# Produces the note name
def name: #:: number| => number
#   . as $pitch_class
    ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"][.]
;

########################################################################

# Inverts a pitch-class
def invert($interval): #:: number|(number) => number
# interval: -11..0..11
#   . as $pitch_class
    math::mod(-. + $interval; 12)
;
def invert: #:: number| => number
#   . as $pitch_class
    math::mod(-.; 12)  # invert(0)
;

# Transposes a pitch-class
def transpose($interval): #:: number|(number) => number
# interval: -11..0..11
#   . as $pitch_class
    math::mod(. + $interval; 12)
;

# pc ∈ pcs
def member($pcset): #:: number|([number]) => boolean
    . as $pitch_class
    | $pcset | contains([$pitch_class])
;

########################################################################
# Intervals

# Produces the chromatic interval (0..11) between two pitch-classes
def interval($pclass): #:: number|(number) => number
#   . as $pitch_class
    math::mod($pclass - .; 12)
;

# Produces the interval-class (0..6) for a chromatic interval
def interval_class: #:: number| => number
#   . as $chromatic_interval
    when(. > 6; 12 - .) # > tritone?
;

# Produces the interval-class (0..6) between two pitch-classes
def interval_class($pclass): #:: number|(number) => number
#   . as $pitch_class
#   interval($pclass) | interval_class
    math::mod($pclass - .; 12) | when(. > 6; 12 - .)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
