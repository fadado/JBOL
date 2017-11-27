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
#    0 == ((label $exit | stream | 1 , break $exit)//0);

# Inverse of `isempty`
def isdot(stream): #:: a|(a->*b) => boolean
    1 == ((label $exit | stream | 1 , break $exit)//0)
;

def deny(s): #:: a|(a->*b) => ?a
    if isempty(s) then . else empty end
;

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
    isdot(stream | predicate or empty)
;
def any: #:: [boolean]| => boolean
    any(.[]; .)
;
def any(predicate): #:: [a]|(a->boolean) => boolean
    any(.[]; predicate)
;

# all(stream; .)
def every(stream): #:: a|(a->*boolean) => boolean
    isempty(stream | . and empty)
;

# any(stream; .)
def some(stream): #:: a|(a->*boolean) => boolean
    isdot(stream | . or empty)
;

#
def add(generator): #:: a|(a->*b) => b^null
    reduce generator as $item
        (null; . + $item)
;
def add(generator; $b): #:: a|(a->*b; b) => b
    reduce generator as $item
        ($b; . + $item)
;

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

# Builtin `select`
#def select(predicate): #:: a|(a->*boolean) => ?a
#    if predicate then . else empty end;

# Complement of select
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

def mapcat(filter):
    reduce (.[] | filter) as $x
        (null; . + $x)
;

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
def iterate($n; filter): #:: a|(number;a->a) => *a
    limit($n; iterate(filter))
;

# f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
def iterate1(filter): #:: a|(a->a) => *a
    filter | iterate(filter)
;
def iterate1($n; filter): #:: a|(number;a->a) => *a
    limit($n; iterate1(filter))
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

########################################################################
# Kleene closures
########################################################################

# Similar to `recurse` and `iterate` but accepting _relations_!

# f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
def K_plus(filter): #:: a|(a->*a) => *a
    def r:
        if length == 0
        then empty
        else
            .[]
            ,
            ([.[] | filter] | r)
        end
    ;
    [filter] | r
;

# f⁰ f¹ f² f³ f⁴ f⁵ f⁶ f⁷ f⁸ f⁹…
def K_star(filter): #:: a|(a->+a) => *a
    . , K_plus(filter)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
