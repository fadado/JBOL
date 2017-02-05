module {
    name: "prelude",
    description: "Common services",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

# α β γ δ   alpha, beta, gamma, delta
# ⊥         bottom
# ¦         broken bar
# ε         epsilon

########################################################################
# Control operators
########################################################################

# Run once a computation.
#
# By default `jq` tries all alternatives. This is the reverse of  *Icon*.
#
def once(generator): #:: (<α>) -> α
    label $exit
    | generator
    | ., break $exit
;

# Boolean context for goal-directed expression evaluation.
def success(generator): #:: (<α>) -> boolean
    (label $exit | generator | 1 , break $exit)//0
    | .==1  # computation generates results
;

def failure(generator): #:: (<α>) -> boolean
    (label $exit | generator | 1 , break $exit)//0
    | .==0  # computation does not generate results
;

# All true? None false?
def every(generator): #:: (<boolean> -> boolean)
    failure(generator | . and empty)
;

# Some true? Not all false?
def some(generator): #:: (<boolean> -> boolean)
    success(generator | . or empty)
;

# Experimental conditionals
#
def when(predicate; action): #:: α|(boolean;β) -> αβ
    if predicate//false then action else . end
;
def unless(predicate; action): #:: α|(boolean;β) -> αβ
    if predicate//false then . else action end
;

def keep(predicate; item): #:: (boolean;α) -> α
    if predicate//false then item else empty end
;
#def keep(p1; i1; p2; i2):
#    keep(p1; i1)
#    , keep(p2; i2)
#;

# Assertions
def assert($predicate; $location; $message): #:: (boolean;object;string) -> α
    if $predicate
    then .
    else
        $location
        | "Assertion failed: "+$message+", file \(.file), line \(.line)"
        | error
    end
;

def assert($predicate; $message): #:: (boolean;string) -> α
    if $predicate
    then .
    else error("Assertion failed: "+$message)
    end
;

########################################################################
# Recursion schemata
########################################################################

#def fold(filter; $b; generator): #:: (α|->β;β;<α>) -> <β>
#    reduce generator as $a ($b; [.,$a]|filter)
#;
#def scan(filter; $b; generator): #:: (α|->β;β;<α>) -> <β>
#    foreach generator as $a ($b; [.,$a]|filter; .)
#;

def unfold(filter; $seed): #:: (α|->[β,α];α) -> <β>
    def r: filter | .[0] , (.[1]|r);
    $seed|r
;

def unfold(filter): #:: α|(α|->[β,α]) -> <β>
    unfold(filter; .)
;

# filter*
def iterate(filter): #:: α|(α|->α) -> <α>
    def r: ., (filter|r);
    r
;

# filter+
def loop(filter): #:: α|(α|->α) -> <α>
    filter | iterate(filter)
;

def tabulate($start; filter): #:: (number;number|->α) -> <α>
    def r: .|filter, (.+1|r);
    $start|r
;
def tabulate(filter): #:: (number|->α) -> <α>
    # tabulate starting at 0
    def r: .|filter, (.+1|r);
    0|r
;

########################################################################
# IO
########################################################################

# Experimental, not yet typed

def EOF:  infinite;
def read: try input catch EOF;

# vim:ai:sw=4:ts=4:et:syntax=jq
