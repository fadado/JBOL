module {
    name: "string/roman",
    description: "Roman numerals encoding and decoding",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";

def encode: #:: number => string
    def _encode($digit; $up):
        def div: (. / 10) | trunc;
        def mod: . % 10;
        def shift: mapstr($up[.]);
        def roman:
            if . < 10
            then $digit[.]
            else (div|roman|shift) + $digit[mod]
            end
        ;
        roman
    ;
    assert(0 < . and . < 4000; "Roman numeral out of range")
    | ["","I","II","III","IV","V","VI","VII","VIII","IX"] as $digit
    | {"I":"X","V":"L","X":"C","L":"D","C":"M"} as $up
    | _encode($digit; $up)
;

def encode($n): #:: (number) => string
    $n|encode
;

def decode: #:: string => number
    def step($sym; $val; $len):
        def r:
            if .roman | startswith($sym)
            then .decimal += $val | .roman |= .[$len:] | r
            else .
            end
         ;
         r
    ;
    reduce (["M",1000], ["CM",900], ["D",500], ["CD",400],
            ["C",100],  ["XC",90],  ["L",50],  ["XL",40],
            ["X",10],   ["IX",9],   ["V",5],   ["IV",4],
            ["I",1])
        as [$sym,$val]
        ({roman:., decimal:0}; step($sym; $val; $sym|length))
    | .decimal
    
;

def decode($roman): #:: (string) => number
    $roman|decode
;

# vim:ai:sw=4:ts=4:et:syntax=jq
