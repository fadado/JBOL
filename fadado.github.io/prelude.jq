module {
    name: "prelude",
    description: "Common services",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

# α β γ δ ε : alpha, beta, gamma, delta, epsilon
# ∅         : empty
# ⊥         : botom

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
    error("!")
;
def cancelled: #:: string| => ∅^⊥
    ignore("!")
;

def fence: #:: α| => α^⊥
    (., error("?"))
;
def fenced: #:: string| => ∅^⊥
    ignore("?")
;

# Run once a computation.  By default `jq` tries all alternatives. This is the
# reverse of  *Icon*.
#
# "first" in stream terms
#
def once(generator): #:: α|(α_<β>) => β^∅
#   try ( generator | fence ) catch fenced
    label $exit | generator | . , break $exit
;

# Boolean context for goal-directed expression evaluation.
def asbool(generator): #:: α|(α_<β>) => boolean
    (label $exit | generator | 1 , break $exit)//0
    | .==1  # computation generates results?
;

# "not isempty" in stream terms
def success(generator): #:: α|(α_<β>) => boolean
    asbool(generator)==true
;

# "isempty" in stream terms
def failure(generator): #:: α|(α_<β>) => boolean
    asbool(generator)==false
;

# select input values if generator succeeds
def yes(generator): #:: α|(α_<β>) => boolean
    select(success(generator))
;

# select input values if generator fails
def not(generator): #:: α|(α_<β>) => boolean
    select(failure(generator))
;

# All true? None false?
def every(generator): #:: α|(α_<boolean>) => boolean
    failure(generator | . and empty)
;

# Some true? Not all false?
def some(generator): #:: α|(α_<boolean>) => boolean
    success(generator | . or empty)
;

# Conditionals
#
def when(predicate; action): #:: α|(α_boolean;α_β) => α^β
    if predicate//false then action else . end
;
def unless(predicate; action): #:: α|(α_boolean;α_β) => α^β 
    if predicate//false then . else action end
;

# keep if true
def keep(predicate; item): #:: α|(α_boolean;α_β) => β^∅
    if predicate//false then item else empty end
;
def keep(predicate): #:: α|(α_boolean) => α^∅
    if predicate//false then . else empty end
;

# rule: A implies C
def rule(antecedent; consequent): #:: α|(α_boolean;α_boolean) => boolean
    if antecedent then consequent else true end
;

# Assertions
def assert(predicate; $location; $message): #:: α|(α_boolean;object;string) => α^⊥
    if predicate
    then .
    else
        $location
        | "Assertion failed: "+$message+", file \(.file), line \(.line)"
        | error
    end
;

def assert(predicate; $message): #:: α|(α_boolean;string) => α^⊥
    if predicate
    then .
    else error("Assertion failed: "+$message)
    end
;

########################################################################
# Recursion schemata
########################################################################

def fold(filter; $a; generator): #:: ([α,β]_α;α;α_<β>) => α
    reduce generator as $b
        ($a; [.,$b]|filter)
;

def scan(filter; $a; generator): #:: ([α,β]_α;α;α_<β>) => <α>
    foreach generator as $b
        ($a; [.,$b]|filter; .)
;

def unfold(filter; $seed): #:: (α_[β,α];α) => <β>
    def r: filter | .[0] , (.[1]|r);
    $seed|r
;

def unfold(filter): #:: (α_[β,α]) => <β>
    unfold(filter; .)
;

def iterate(filter): #:: α|(α_α) => <α>
    def r: . , (filter|r);
    r
;

def loop(filter): #:: α|(α_α) => <α>
    filter | iterate(filter)
;

def tabulate($start; filter): #:: (number;number_α) => <α>
    def r: filter , (.+1|r);
    $start|r
;
def tabulate(filter): #:: (number_α) => <α>
    # tabulate starting at 0
    def r: filter , (.+1|r);
    0|r
;

# vim:ai:sw=4:ts=4:et:syntax=jq
