module {
    name: "prelude",
    description: "Common services",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

# α β γ δ   Types: alpha, beta, gamma, delta
# ⦵         The empty stream (empty, fail...)
# ⦺         Error, abort
# ⊥         Bottom: 

########################################################################
# Control operators
########################################################################

# Run once a computation.
#
# By default `jq` tries all alternatives. This is the reverse of  *Icon*.
#
def once(g): #:: (<α>) -> α|
    label $pipe
    | g
    | ., break $pipe
;

# Boolean context for goal-directed expression evaluation.
def success(g): #:: (<α>) -> boolean
    (label $block | g | 1 , break $block)//0
    | .==1  # computation generates results
;

def failure(g): #:: (<α>) -> boolean
    (label $block | g | 1 , break $block)//0
    | .==0  # computation does not generate results
;

# All true? None false?
def every(g): #:: (<boolean> -> boolean)
    failure(g | if . then empty else . end)
;

# Some true? Not all false?
def some(g): #:: (<boolean> -> boolean)
    success(g | if . then . else empty end)
;

# Assertions
def assert($p; $loc; $msg): #:: (boolean;object;string) -> α
    if $p
    then .
    else
        $loc
        | "Assertion failed: "+$msg+", file \(.file), line \(.line)"
        | error
    end
;

def assert($p; $msg): #:: (boolean;string) -> α
    if $p
    then .
    else error("Assertion failed: "+$msg)
    end
;

########################################################################
# Recursion schemata
########################################################################

#def fold(f; $b; g): #:: (α|->β;β;<α>) -> <β>
#    reduce g as $a ($b; [.,$a]|f)
#;
#def scan(f; $b; g): #:: (α|->β;β;<α>) -> <β>
#    foreach g as $a ($b; [.,$a]|f)
#;

def unfold(f; $seed): #:: (α|->[β,α];α) -> <β>
    def r: f | .[0] , (.[1]|r);
    $seed|r
;

def unfold(f): #:: α|(α|->[β,α]) -> <β>
    # . as $seed
    unfold(f; .)
;

def iterate(f): #:: α|(α|->α) -> <α>
    def r: ., (f|r);
    r
;

def tabulate($from; f): #:: (number;number|->α) -> <α>
    def r: .|f, (.+1|r);
    $from|r
;
def tabulate(f): #:: (number|->α) -> <α>
    # tabulate from 0
    def r: .|f, (.+1|r);
    0|r
;

########################################################################
# IO
########################################################################

def EOF:  infinite;
def read: try input catch EOF;

# vim:ai:sw=4:ts=4:et:syntax=jq
