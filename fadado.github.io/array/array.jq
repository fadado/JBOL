module {
    name: "array",
    description: "Generic and stack array operations",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
import "fadado.github.io/math" as math;

########################################################################

# Remove all x from array
# Use set::remove/1 to remove only one `x`
def remove($x): #:: [a]|(a) => [a]
    indices($x) as $ix
    | if $ix != []
      then del(.[$ix[]]) end
;

# Is the array sorted?
def sorted: #:: [a] => boolean
    every(
        range(0;length-1) as $i
        | ($i+1) as $j
        | .[$i] <= .[$j])
;

# Are all elements equal?
def uniform: #:: [a] => boolean
    every(
        range(0;length-1) as $i
        | ($i+1) as $j
        | .[$i] == .[$j])
;

# unknown value for index?
def unknown($i): #:: [a]|(number) => boolean
    has($i) and .[$i]==null
;

# Select elements with even indices
def evens: #:: [a] => [a]
    if length > 0
    then [.[range(0;length;2)]] end
;

# Select elements with odd indices
def odds: #:: [a] => [a]
    if length > 0
    then [.[range(1;length;2)]] end
;

# Copy here builtin
def reverse: #:: [a] => [a]
    if length > 0
    then [.[length-1-range(0;length)]] end
;

########################################################################
#  Stack operations

def push($x): #:: [a]|(a) => [a]
    .[length] = $x
;

def pop: #:: [a] => [a]
    del(.[-1]) # [] if empty
;

def top: #:: [a] => a^null
    .[-1] # null if empty
;

#
# Not optimized `zip` => def zip($a; $b): [$a, $b] | transpose[];
#

#
def zip($a; $b): #:: ([a];[b]) => *[a,b]
    range(0; math::max($a,$b | length))
    | [$a[.], $b[.]]
;

# Generalized `zip` for 2 or more arrays.
#
def zip: #:: [[a],[b]...]| => *[a,b,...]
    . as $in
    | math::max(.[] | length) as $longest
    | length as $n
    | foreach range(0;$longest) as $j (null;
        reduce range(0;$n) as $i
            ([]; . + [$in[$i][$j]]))
;

# vim:ai:sw=4:ts=4:et:syntax=jq
