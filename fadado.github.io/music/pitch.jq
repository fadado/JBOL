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
import "fadado.github.io/string/regexp" as re;

########################################################################
# Names used in type declarations
#
# PITCH: 0..127; as string: (C0..G10), MIDI based octave count
# PI (pitch interval): -127..127 (has direction)
#
# Useful primitives:
#   + math::abs :: PI => unordered PI

# Produces a new pitch
def new: #:: <number^string> => PITCH
    if type == "number" then
        if 0 <= . and . <= 127 # . is a pitch in the range 0..127
        then .
        else "Pitch out of range: \(.)" | error
        end
    elif type == "string" then
        if test("^[A-G][#sbf]?(?:[0-9]|10)$") # . is a note name with octave
        then
            match("^(?<n>[A-G])(?<a>[#sbf])?(?<o>[0-9]|10)$")
            | re::tomap as $m
            | {"C":0,"D":2,"E":4,"F":5,"G":7,"A":9,"B":11}[$m["n"]] as $n
            | $m["o"]|tonumber * 12
            + if $m["a"]=="#" or $m["a"]=="s"
              then $n+1     # sharp
              elif $m["a"]=="b" or $m["a"]=="f"
              then $n-1     # flat
              else $n
              end
        else
            "Malformed pitch: \(.)" | error
        end
    else type | "Type error: expected number or string, not \(.)" | error
    end
;
def new($x): #:: (<number^string>) => PITCH
    $x | new
;

# Produces the note name
def name: #:: PITCH => string
    ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"][. % 12]
;

# Formats a pitch (C0..G10)
def format: #:: PITCH => string
    "\(name)\(./12|floor)"
;

########################################################################

## Add a directed pitch interval to the pitch
def transpose($interval): #:: PITCH|(PI) => PITCH
    . + $interval
    | unless(0 <= . and . <= 127;
        "Pitch out of range: \(.)" | error)
;

# Produces the pitch interval (-127..127) between two pitches
def interval($p): #:: PITCH|(PITCH) => PI
    $p - .
;

# vim:ai:sw=4:ts=4:et:syntax=jq
