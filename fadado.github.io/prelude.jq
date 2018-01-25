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
# Redefine some jq primitives
########################################################################

# Builtin `isempty`
#def isempty(stream): #:: a|(a->*b) => boolean
#    0 == ((label $fence | stream | (1 , break $fence))//0);

# Reverse of `isempty`
def succeeds(stream): #:: a|(a->*b) => boolean
    1 == ((label $fence | stream | (1 , break $fence))//0)
;

# all(stream; .)
def every(stream): #:: a|(a->*boolean) => boolean
    isempty(stream | . and empty)
;

# any(stream; .)
def some(stream): #:: a|(a->*boolean) => boolean
    succeeds(stream | . or empty)
;

########################################################################
# Stolen from SNOBOL: ABORT and FENCE
########################################################################

# Breaks out the current filter
# For constructs like:
#   try (A | possible abortion | B)
def abort: #:: a => !
    error("!")
;

# One way pass. Usage:
#   try (A | fence | B)
def fence: #:: a| => a!
    (. , abort)
;

# Catch helpers. Usage:
#   try (...) catch _abort_(result)
#   . as $_ | try (A | possible abortion | B) catch _abort_($_)
def _abort_(result): #:: string| => a!
    if . == "!" then result else error end
;
#   try (...) catch _abort_
def _abort_: #:: string| => @!
    if . == "!" then empty else error end
;

########################################################################
# Predicate based conditionals
########################################################################

# Builtin `select`
#def select(predicate): #:: a|(a->*boolean) => ?a
#    if predicate then . else empty end;

# Complement of select
def reject(predicate): #:: a|(a->*boolean) => ?a
    if predicate then empty else . end
;

# One branch conditionals
def when(predicate; action): #:: a|(a->boolean;a->*a) => *a
    if predicate then action else . end
;
def unless(predicate; action): #:: a|(a->boolean;a->*a) => *a 
    if predicate then . else action end
;

#def neg(generator): #:: a|(a->*b) => ?a
#    reject(succeeds(generator))
#;
#def yep(generator): #:: a|(a->*b) => ?a
#    select(succeeds(generator))
#;

########################################################################
# Assertions
########################################################################

def assert(predicate; $location; $message): #:: a|(a->boolean;LOCATION;string) => a!
    if predicate then .
    else
        $location
        | "Assertion failed: "+$message+", file \(.file), line \(.line)"
        | error
    end
;

def assert(predicate; $message): #:: a|(a->boolean;string) => a!
    if predicate then .
    else
        "Assertion failed: "+$message
        | error
    end
;

########################################################################
# Recursion schemata
########################################################################

########################################################################
# Stream of function powers

# f⁰ f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
def iterate(f): #:: a|(a->a) => +a
    # . as $base
    def r: #:: a => +a
        . , (f|r) # until `f` fails
    ; r
;
def iterate($n; f): #:: a|(number;a->a) => *a
    select($n > 0)
    | limit($n; iterate(f))
;

# f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
def iterate1(f): #:: a|(a->a) => *a
    f | iterate(f)
;
def iterate1($n; f): #:: a|(number;a->a) => *a
    select($n > 0)
    | limit($n; iterate1(f))
;

########################################################################
# Stream of relation powers

# g⁰ g¹⁺ g²⁺ g³⁺ g⁴⁺ g⁵⁺ g⁶⁺ g⁷⁺ g⁸⁺ g⁹⁺…
def deepen(g): #:: a|(a->*a) => +a
    # . as $base
    def r: #:: a => +a
        . , (r|g)
    ; r
;
# g⁰⁺ g¹⁺ g²⁺ g³⁺ g⁴⁺ g⁵⁺ g⁶⁺ g⁷⁺ g⁸⁺ g⁹⁺…
def deepen(base; g): #:: x|(x->*a;a->*a) => *a
    def r: #:: a => +a
        base , (r|g)
    ; r
;

########################################################################
# Variant

# g⁰ g¹⁺ g²⁺ g³⁺ g⁴⁺ g⁵⁺ g⁶⁺ g⁷⁺ g⁸⁺ g⁹⁺…
def xdeepen(g): #:: a|(a->*a) => +a
    # [.] as $base
    def r: #:: [a] => +a
        # .[] , ( [.[]|g] | select(length > 0) | r )
        if length != 0
        then # until `g` fails
            .[] , ( [.[]|g] | r )
        else empty end
    ; [.] | r
;
# g⁰⁺ g¹⁺ g²⁺ g³⁺ g⁴⁺ g⁵⁺ g⁶⁺ g⁷⁺ g⁸⁺ g⁹⁺…
def xdeepen(base; g): #:: x|(x->*a;a->*a) => *a
    def r: #:: [a] => *a
        # .[] , ( [.[]|g] | select(length > 0) | r )
        if length != 0
        then # until `g` fails
            .[] , ( [.[]|g] | r )
        else empty end
    ; [base] | r
;

########################################################################
# Apply functions to ℕ

# fₙ fₙ₊₁ fₙ₊₂ fₙ₊₃ fₙ₊₄ fₙ₊₅ fₙ₊₆ fₙ₊₇ fₙ₊₈ fₙ₊₉…
def tabulate($n; f): #:: (number;number->a) => *a
#   $n | iterate(.+1) | f
    def r: f , (.+1|r);
    $n|r
;
# f₀ f₁ f₂ f₃ f₄ f₅ f₆ f₇ f₈ f₉…
def tabulate(f): #:: (number->a) => *a
#   0 | iterate(.+1) | f
    def r: f , (.+1|r);
    0|r
;

########################################################################
# Fold/unfold family of patterns

#def fold(f; $a; generator): #:: x|([a,b]->a;a;x->*b) => a
#    reduce generator as $b
#        ($a; [.,$b]|f)
#;

#def scan(f; generator): #:: x|([a,b]->a;x->*b) => *a
#    foreach generator as $b
#        (.; [.,$b]|f; .)
#;
#def scan(f; $a; generator): #:: x|([a,b]->a;a;x->*b) => *a
#    $a|scan(f; generator)
#;

#def mapcat(f; $id):
#    reduce (.[] | f) as $x
#        ($id; . + $x)
#;

# Fold opposite
def unfold(f; $seed): #:: (a->[b,a];a) => *b
    def r: f | .[0] , (.[1]|r);
    $seed|r
;

def unfold(f): #:: a|(a->[b,a]) => *b
    unfold(f; .)
;

########################################################################
# Better versions for builtins, to be removed...
########################################################################

def all(stream; predicate): #:: a|(a->*b;b->boolean) => boolean
    isempty(stream | predicate and empty)
;
def all: #:: [boolean]| => boolean
    all(.[]; .)
;
def all(predicate): #:: [a]|(a->boolean) => boolean
    all(.[]; predicate)
;

def any(stream; predicate): #:: a|(a->*b;b->boolean) => boolean
    succeeds(stream | predicate or empty)
;
def any: #:: [boolean]| => boolean
    any(.[]; .)
;
def any(predicate): #:: [a]|(a->boolean) => boolean
    any(.[]; predicate)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
