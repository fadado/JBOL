module {
    name: "prelude",
    description: "Common services",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

########################################################################
# Stolen from SNOBOL: ABORT (renamed `cancel`) and FENCE
########################################################################

# Exits current filter
def cancel: #:: => !
    error("!")
;

# For constructs like:
#   try (A | possible cancellation | B) catch canceled
def canceled: #:: string| => @!
    if . == "!" then empty else error end
;

# One way pass. Usage:
#   try (A | fence | B) catch canceled
def fence: #:: a| => a!
    (. , cancel)
;

########################################################################
# Predicate based conditionals
########################################################################

# Builtin
#def select(predicate): #:: a|(a->*boolean) => ?a
#    if predicate then . else empty end
#;

# Contrary of select
def reject(predicate): #:: a|(a->*boolean) => ?a
    if predicate then empty else . end
;

# One branch conditionals
def when(predicate; action): #:: a|(a->boolean;a->*b) => a^*b
    if predicate then action else . end
;
def unless(predicate; action): #:: a|(a->boolean;a->*b) => a^*b 
    if predicate then . else action end
;

# Like select but cancelling
def upto(predicate): #:: a|(a->boolean) => a!
    if predicate then . else cancel end
;

# Fence at predicate
def till(predicate): #:: a|(a->boolean) => a!
    if predicate then (. , cancel) else empty end
;

########################################################################
# Goal-directed evaluation
########################################################################

# Run once a computation.  By default `jq` tries all alternatives. This is the
# reverse of  Icon (Icon `every` is the JQ default).
#
# "first" in stream terms
def once(goal): #:: a|(a->*b) => ?b
    label $exit | goal | . , break $exit
;

# "not isempty" in stream terms
# "as bool": casts goal to boolean; boolean to goal: b//empty
def success(goal): #:: a|(a->*b) => boolean
#   (once(goal) | true)//false
    (label $exit | goal | true , break $exit)//false
;

# "isempty" in stream terms
# "as bool | not": casts goal to boolean 
def failure(goal): #:: a|(a->*b) => boolean
#   (once(goal) | true)//false | not
    (label $exit | goal | true , break $exit)//false | not
;

# select input value if goal succeeds
def allow(goal): #:: a|(a->*b) => ?a
#   select(success(goal))
#   if success(goal) then . else empty end
    (. as $a | label $exit | goal | $a , break $exit)
;

# reject input value if goal succeeds
def deny(goal): #:: a|(a->*b) => ?a
#   select(failure(goal))
    if failure(goal) then . else empty end
;

# All goals true?  Some goal true?
def every(goal): #:: a|(a->*boolean) => boolean
#   failure(goal | . and empty)
    (label $exit | (goal | . and empty) | true , break $exit)//false | not
;
def some(goal): #:: a|(a->*boolean) => boolean
#   success(goal | . or empty)
    (label $exit | (goal | . or empty) | true , break $exit)//false
;

########################################################################
# Assertions
########################################################################

def assert(predicate; $location; $message): #:: a|(a->boolean;LOCATION;string) => a!
    if predicate
    then .
    else
        $location
        | "Assertion failed: "+$message+", file \(.file), line \(.line)"
        | error
    end
;

def assert(predicate; $message): #:: a|(a->boolean;string) => a!
    if predicate
    then .
    else
        "Assertion failed: "+$message
        | error
    end
;

########################################################################
# Recursion schemata
########################################################################

# Builtin
# =======================
# iterate/1: f⁰ f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
# iterate/2
# repeat/1: f f f f f f…
# while/2
# until/2

def fold(filter; $a; generator): #:: x|([a,b]->a;a;x->*b) => a
    reduce generator as $b
        ($a; [.,$b]|filter)
;

def scan(filter; generator): #:: x|([a,b]->a;x->*b) => *a
    foreach generator as $b
        (.; [.,$b]|filter; .)
;
def scan(filter; $a; generator): #:: x|([a,b]->a;a;x->*b) => *a
    $a|scan(filter; generator)
;

# f⁰ f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
def iterate(filter): #:: a|(a->a) => *a
    def r: . , (filter|r);
    r
;

# f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
def iterate1(filter): #:: a|(a->a) => *a
    filter | iterate(filter)
;

def tabulate($start; filter): #:: (number;number->a) => *a
#   $start | iterate(.+1) | filter
    def r: filter , (.+1|r);
    $start|r
;
# tabulate starting at 0
def tabulate(filter): #:: (number->a) => *a
#   0 | iterate(.+1) | filter
    def r: filter , (.+1|r);
    0|r
;

def unfold(filter; $seed): #:: (a->[b,a];a) => *b
    def r: filter | .[0] , (.[1]|r);
    $seed|r
;

def unfold(filter): #:: a|(a->[b,a]) => *b
    unfold(filter; .)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
