module {
    name: "music/interval-pattern",
    description: "Ordered pitch-class set intervals pattern",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/music/pitch-class" as pc;

########################################################################
# Names used in type declarations
#
# PCLASS (pitch-class): 0..11
# PCSET (pitch-class set): [PCLASS]
# PCI (pitch-class interval): 0..11 (has not direction) 
# PATTERN: [PCI]

########################################################################
# Intervals succession pattern
# Known as directed-interval vector, interval succession,  interval string,
# etc.

def new: #:: PCSET => PATTERN
    . as $pcset
    | [range(length), 0] as $ndx
    | [range(length) as $i | $pcset[$ndx[$i]]|pc::interval($pcset[$ndx[$i+1]])]
#   | assert(add == 12)
;

# Hexadecimal format
def format: #:: PATTERN => string
    reduce (.[] | math::tobase(16)) as $s
        (""; .+$s)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
