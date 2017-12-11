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
def new: #:: <number^string> => PCLASS
    if type == "number" then
        pitch::new % 12
    elif type == "string" then
        if test("^[0-9te]$")
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
def new($x): #:: (<number^string>) => PCLASS
    $x | new
;

# Format a pitch-class as a string
def format: #:: PCLASS => string
    ["0","1","2","3","4","5","6","7","8","9","t","e"][.]
;

# Produces the note name
def name($flats): #:: PCLASS|(boolean) => string
    if $flats
    then ["C","D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"][.]
    else ["C","C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"][.]
    end
;
def name: #:: PCLASS => string
    ["C","C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"][.]
;

########################################################################

# Transposes a pitch-class
def transpose($i): #:: PCLASS|(PCI) => PCLASS
    math::mod(. + $i; 12)
;

# Inverts a pitch-class
def invert: #:: PCLASS => PCLASS
    when(. != 0; 12 - .)
;
def invert($i): #:: PCLASS|(PCI) => PCLASS
    math::mod($i - .; 12)
#   invert | transpose($i)
#   math::mod(-. + $i; 12)
#   math::mod(12 - . + $i; 12)
;

# Produces the pitch-class interval (0..11) between two pitch-classes
def interval($pc): #:: PCLASS|(PCLASS) => PCI
    math::mod($pc - .; 12)
;

# Produces the interval-class (0..6) for a pitch-class interval
def iclass: #:: PCI => IC
    when(. > 6; 12 - .)     # . > tritone?
;

# Produces the interval-class (0..6) between two pitch-classes
def interval_class($pc): #:: PCLASS|(PCLASS) => IC
    math::mod($pc - .; 12) | when(. > 6; 12 - .)
#   interval($pc) | iclass
#   math::mod(math::min($pc - .; . - $pc); 12)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
