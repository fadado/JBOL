module {
    name: "prelude",
    description: "Common services",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

# ∅ @ : empty stream
# ⊥ ! : bottom

########################################################################
# ABORT (renamed `cancel`) and FENCE from SNOBOL
########################################################################

def cancel: #:: ⊥
    error("!")
;

def canceled: #:: string| => ∅^⊥
    if . == "!" then empty else error end
;

def fence: #:: a| => a^⊥
    (. , cancel)
;

def keep(predicate): #:: a|(a->boolean) => a^⊥
    if predicate then . else cancel end
;

def discard(predicate): #:: a|(a->boolean) => a^⊥
    if predicate then cancel else . end
;

########################################################################
# Goal-directed evaluation
########################################################################

# "not isempty" in stream terms
def success(goal): #:: a|(a->*b) => boolean
    (label $exit | goal | 1 , break $exit)//0
    | .==1  # computation generates results?
;

# "isempty" in stream terms
def failure(goal): #:: a|(a->*b) => boolean
    (label $exit | goal | 1 , break $exit)//0
    | .==0  # computation generates no results?
;

# select input value if goal fails
def not(goal): #:: a|(a->*b) => ?a
    if success(goal) then empty else . end
;

# select input value if goal succeeds
def cond(goal): #:: a|(a->*b) => ?a
    if success(goal) then . else empty end
;

# Predicate based conditionals
#
def when(predicate; action): #:: a|(a->boolean;a->*b) => a^*b
    if predicate//false then action else . end
;
def unless(predicate; action): #:: a|(a->boolean;a->*b) => a^*b 
    if predicate//false then . else action end
;

# Run once a computation.  By default `jq` tries all alternatives. This is the
# reverse of  Icon (Icon `every` is the JQ default).
#
# "first" in stream terms
def once(goal): #:: a|(a->*b) => ?b
    label $exit | goal | . , break $exit
;

# All true?
def every(generator): #:: a|(a->*boolean) => boolean
    failure(generator | . and empty)
;

# Some true?
def some(generator): #:: a|(a->*boolean) => boolean
    success(generator | . or empty)
;

# Contrary of select
def reject(predicate): #:: a|(a->*boolean) => ?a
    if predicate then empty else . end
;

########################################################################
# Assertions
########################################################################

def assert(predicate; $location; $message): #:: a|(a->boolean;LOCATION;string) => a^⊥
    if predicate
    then .
    else
        $location
        | "Assertion failed: "+$message+", file \(.file), line \(.line)"
        | error
    end
;

def assert(predicate; $message): #:: a|(a->boolean;string) => a^⊥
    if predicate
    then .
    else error("Assertion failed: "+$message)
    end
;

########################################################################
# Recursion schemata
########################################################################

# Builtin
# =======================
# recurse/1: f⁰ f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
# recurse/2
# repeat/1: f f f f f f…
# while/2
# until/2

# As ilustration
# =======================
#def fold(filter; $a; generator): #:: x|([a,b]->a;a;x->*b) => a
#    reduce generator as $b
#        ($a; [.,$b]|filter)
#;
#
#def scan(filter; generator): #:: x|([a,b]->a;x->*b) => *a
#    foreach generator as $b
#        (.; [.,$b]|filter; .)
#;
#def scan(filter; $a; generator): #:: x|([a,b]->a;a;x->*b) => *a
#    $a|scan(filter; generator)
#;

# f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
def recurse1(filter): #:: a|(a->a) => *a
    filter | recurse(filter)
;

def tabulate($start; filter): #:: (number;number->a) => *a
#   $start | recurse(.+1) | filter
    def r: filter , (.+1|r);
    $start|r
;
# tabulate starting at 0
def tabulate(filter): #:: (number->a) => *a
#   0 | recurse(.+1) | filter
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
