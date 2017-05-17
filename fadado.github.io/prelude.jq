module {
    name: "prelude",
    description: "Common services",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

# ∅ : empty stream
# ⊥ : bottom

########################################################################
# Control operators
########################################################################

# Abort (cancel) and fence from SNOBOL for constructs like:
#   try ( generator | fence ) catch fenced

def ignore($s): #:: string|(string) => ∅^⊥
    if . == $s
    then empty # ∅
    else error # ⊥ 
    end
;

def cancel: #:: ⊥
    error("¡")
;
def cancelled: #:: string| => ∅^⊥
    ignore("¡")
;

def fence: #:: a| => a^⊥
    (., error("¿"))
;
def fenced: #:: string| => ∅^⊥
    ignore("¿")
;

# Run once a computation.  By default `jq` tries all alternatives. This is the
# reverse of  *Icon*.
#
# "first" in stream terms
#
def once(generator): #:: a|(a->*b) => ?b
#   try ( generator | fence ) catch fenced
    label $exit | generator | . , break $exit
;

# Boolean context for goal-directed expression evaluation.
def asbool(generator): #:: a|(a->*b) => boolean
    (label $exit | generator | 1 , break $exit)//0
    | .==1  # computation generates results?
;

# "not isempty" in stream terms
def success(generator): #:: a|(a->*b) => boolean
    asbool(generator)==true
;

# "isempty" in stream terms
def failure(generator): #:: a|(a->*b) => boolean
    asbool(generator)==false
;

# select input values if generator succeeds
def yes(generator): #:: a|(a->*b) => boolean
    select(success(generator))
;

# select input values if generator fails
def not(generator): #:: a|(a->*b) => boolean
    select(failure(generator))
;

# All true? None false?
def every(generator): #:: a|(a->*boolean) => boolean
    failure(generator | . and empty)
;

# Some true? Not all false?
def some(generator): #:: a|(a->*boolean) => boolean
    success(generator | . or empty)
;

# Conditionals
#
def when(predicate; action): #:: a|(a->boolean;a->b) => a^b
    if predicate//false then action else . end
;
def unless(predicate; action): #:: a|(a->boolean;a->b) => a^b 
    if predicate//false then . else action end
;

# keep if true
def keep(predicate; item): #:: a|(a->boolean;a->b) => ?b
    if predicate//false then item else empty end
;
def keep(predicate): #:: a|(a->boolean) => ?a
    if predicate//false then . else empty end
;

# rule: A implies C
def rule(antecedent; consequent): #:: a|(a->boolean;a->boolean) => boolean
    if antecedent then consequent else true end
;

# Assertions
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

def unfold(filter; $seed): #:: (a->[b,a];a) => *b
    def r: filter | .[0] , (.[1]|r);
    $seed|r
;

def unfold(filter): #:: a|(a->[b,a]) => *b
    unfold(filter; .)
;

def iterate(filter): #:: a|(a->a) => *a
    def r: . , (filter|r);
    r
;

def loop(filter): #:: a|(a->a) => *a
    filter | iterate(filter)
;

def tabulate($start; filter): #:: (number;number->a) => *a
    def r: filter , (.+1|r);
    $start|r
;
def tabulate(filter): #:: (number->a) => *a
    # tabulate starting at 0
    def r: filter , (.+1|r);
    0|r
;

# vim:ai:sw=4:ts=4:et:syntax=jq
