module {
    name: "prelude",
    description: "Flow control services",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

########################################################################
# Variations on some JQ primitives
########################################################################

# Reverse of `isempty`
def nonempty(stream): #:: a|(a->*b) => boolean
    (label $pipe | stream | (true , break $pipe))
    // false
;

# all(stream; .)
def every(stream): #:: a|(a->*boolean) => boolean
    isempty(stream and empty)
;

# any(stream; .)
def some(stream): #:: a|(a->*boolean) => boolean
    nonempty(stream or empty)
;

# Enhanced `select`
def select(predicate; action): #:: a|(a->*boolean;a->*b) => *b
    if predicate then action else empty end
;

# Accept only productive streams
def accept(stream): #:: a|(a->*b) => ?a
    if nonempty(stream) then . else empty end
;

def accept(stream; action): #:: a|(a->*c;a->*b) => *b
    if nonempty(stream) then action else empty end
;

# Complement of `select`
def reject(predicate): #:: a|(a->*boolean) => ?a
    if predicate then empty else . end
;

# Strong select
def guard(predicate): #:: a|(a->boolean) => a!
    if predicate then . else abort end
;

# One branch conditionals
def when(predicate; action): #:: a|(a->boolean;a->*a) => *a
    if predicate then action else . end
;
def unless(predicate; action): #:: a|(a->boolean;a->*a) => *a 
    if predicate then . else action end
;

########################################################################
# Stolen from SNOBOL: ABORT and FENCE
########################################################################

# Breaks out the current filter
# For constructs like:
#   try (A | possible abortion | B)
def abort: #:: a => !
    error("~!~")
;

# One way pass. Usage:
#   try (A | fence | B)
def fence: #:: a => a!
    (. , abort)
;

# Catch helpers. Usage:
#   try (...) catch _abort_(result)
#   . as $_ | try (A | possible abortion | B) catch _abort_($_)
def _abort_(result): #:: string| => a!
    if . == "~!~" then result else error(.) end
;
#   try (...) catch _abort_
def _abort_: #:: string| => @!
    if . == "~!~" then empty else error(.) end
;

########################################################################
# Assertions
########################################################################

def assert(predicate; $location; $message): #:: a|(a->boolean;LOCATION;string) => a!
    if predicate then .
    else
        $location
        | error("Assertion failed: "+$message+", file \(.file), line \(.line)")
    end
;

def assert(predicate; $message): #:: a|(a->boolean;string) => a!
    if predicate then .
    else
        error("Assertion failed: "+$message)
    end
;

########################################################################
# Recursion schemata
########################################################################

# Additions to builtin recurse, while, until...

# Generate ℕ
def seq: #:: => *number
    0|recurse(.+1) # seq(1)
;
def seq($a): #:: (number) => *number
    $a|recurse(.+1) # seq($a)
;
def seq($a; $d): #:: (number;$number) => *number
    $a|recurse(.+$d) # seq($a; $d)
;

#
# Stream of relation powers
#

# g⁰ g¹ g² g³ g⁴ g⁵ g⁶ g⁷ g⁸ g⁹…
# Breadth-first search
def iterate(init; g): #:: a|(a->*b;b->*b) => *b
    def r:
#        .[] , (map(g) | accept(.[]; r))
         .[] , ([.[]|g] | select(length > 0; r))
    ;
    [init] | r
;
def iterate(g): #:: a|(a->*a) => +a
    iterate(.; g)
;

# g⁰ g¹ g² g³ g⁴ g⁵ g⁶ g⁷ g⁸ g⁹…
# Stack leak, diverges if `init` fails, etc.
def reiterate(init; g): #::  a|(a->*a;a->*a) => *a!
#   def r: init , (r|g);
#   r
    def r(h): h , r(h|g);
    r(init)
;
def reiterate(g): #:: a|(a->*a) => +a
    reiterate(.; g)
;

#
# Fold/unfold family of patterns
#

#def fold(f; $a; g): #:: x|([a,b]->a;a;x->*b) => a
#    reduce g as $b
#        ($a; [.,$b]|f)
#;

#def scan(f; g): #:: x|([a,b]->a;x->*b) => *a
#    foreach g as $b
#        (.; [.,$b]|f; .)
#;
#def scan(f; $a; g): #:: x|([a,b]->a;a;x->*b) => *a
#    $a|scan(f; g)
#;

# Fold _opposite_
def unfold(f): #:: a|(a->[b,a]) => *b
    def r: f as [$b,$a] | $b , ($a|r);
    r
;

########################################################################
# Better versions for builtins
########################################################################

# Renamed map_values
def mapval(f): #:: <a>|(a->*b) => <b>
    .[] |= f
;

# map and add in one pass (catenable: x+x)
def mapadd(f): #:: <a>|(a->*b) => ?b
    reduce (.[] | f) as $x
        (null; . + $x)
    // empty
;

# Split string, map characters (length one strings) and concat results
def mapstr(f): #:: string|(char->*char) => string
    reduce ((./"")[] | f) as $s
        (""; . + $s)
;

# Variation on `with_entries`
#
# PAIR: {"name":string, "value":value}
#
def mapobj(filter): #:: object|(PAIR->PAIR) => object
    reduce (keys_unsorted[] as $k
            | {name: $k, value: .[$k]}
            | filter
            | {(.name): .value})
        as $pair ({}; . + $pair)
;

# Does not diverge with empty parameter
def repeat(g): #:: a|(a->*b) => *b
    def r: g , r;
    accept(g; r)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
