module {
    name: "math",
    description: "Misc. mathematical functions",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

########################################################################
# Simple utilities

def even($n):
    $n%2 == 0
;

def odd($n):
    $n%2 != 0
;

# Absolute value
def abs($n): #:: (number) -> number
    $n|length
;

# Greatest common divisor
def gcd($a; $b): #:: (number;number) -> number
    if $b == 0
    then $a
    else gcd($b; $a % $b)
    end
;

# Reductions ###########################################################

def sum(g): #:: (<number>) -> number
    reduce g as $item (0; .+$item)
;

def product(g): #:: (<number>) -> number
    reduce g as $item (1; .*$item)
;

def maximum(g): #:: (<number>) -> number
    reduce g as $item (-(infinite); if $item > . then $item else . end)
;

def minimum(g): #:: (<number>) -> number
    reduce g as $item (infinite; if $item < . then $item else . end)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
