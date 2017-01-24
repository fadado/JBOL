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

def even($n): #:: (number) -> boolean
    $n%2 == 0
;

def odd($n): #:: (number) -> boolean
    $n%2 != 0
;

# Absolute value
def abs($n): #:: (number) -> number
    $n|length
;

# Greatest common divisor
def gcd($m; $n): #:: (number;number) -> number
    if $n == 0
    then $m
    else gcd($n; $m % $n)
    end
;

# Min and max
def min($a; $b): #:: (number;number) -> number
    if $a < $b then $a else $b end
;
def max($a; $b): #:: (number;number) -> number
    if $a > $b then $a else $b end
;

# Reductions ###########################################################

def sum(generator): #:: (<number>) -> number
    reduce generator as $item (0; .+$item)
;

def product(generator): #:: (<number>) -> number
    reduce generator as $item (1; .*$item)
;

def maximum(generator): #:: (<number>) -> number
    reduce generator as $item (-(infinite); max($item; .))
;

def minimum(generator): #:: (<number>) -> number
    reduce generator as $item (infinite; min($item; .))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
