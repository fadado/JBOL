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
# Names used in type declarations
#
# PCLASS (pitch-class): 0..11; as string: 0..9,t,e
# PCI (pitch-class interval): 0..11 (has not direction) 
# IC (interval-class): 0..6 (assume interval inversion equivalence)

# Produces the pitch-class corresponding to a pitch
def new: #:: <number^string>| => PCLASS
#   . as $x
    if type == "number" then
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
def new($x): #::(<number^string>) => PCLASS
    $x | new
;

# Format a pitch-class as a string
def format: #:: PCLASS| => string
#   . as $pclass
    ["0","1","2","3","4","5","6","7","8","9","t","e"][.]
;

# Produces the note name
def name: #:: PCLASS| => string
#   . as $pclass
    ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"][.]
;

########################################################################

# Transposes a pitch-class
def transpose($interval): #:: PCLASS|(PCI) => PCLASS
#   . as $pclass
    math::mod(. + $interval; 12)
;

# Inverts a pitch-class
def invert: #:: PCLASS| => PCLASS
#   . as $pclass
    12 - .
;
def invert($interval): #:: PCLASS|(PCI) => PCLASS
#   . as $pclass
    math::mod($interval - .; 12)
#   invert | transpose($interval)
#   math::mod(-. + $interval; 12)
#   math::mod(12 - . + $interval; 12)
;

# Produces the pitch-class interval (0..11) between two pitch-classes
def interval($pc): #:: PCLASS|(PCLASS) => PCI
#   . as $pclass
    math::mod($pc - .; 12)
;

# Produces the interval-class (0..6) for a pitch-class interval
def iclass: #:: PCI| => IC
#   . as $chromatic_interval
    when(. > 6; 12 - .) # > tritone?
;

# Produces the interval-class (0..6) between two pitch-classes
def interval_class($pc): #:: PCLASS|(PCLASS) => IC
#   . as $pclass
    math::mod($pc - .; 12) | when(. > 6; 12 - .)
#   interval($pc) | iclass
#   math::mod(math::min($pc - .; . - $pc); 12)
;

# vim:ai:sw=4:ts=4:et:syntax=jq