module {
    name: "math/sequence",
    description: "Mathematical sequences",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/math";

# Arithmetic sequences #################################################

# CF:
#   a(n) = a0+d*n
# RR:
#   a(0) = a0
#   a(n) = a(n-1)+d
#
def arithmetic($a; $d): #:: (number;number) => *number
#   seq($a; $d)
    $a|recurse(. + $d)
;

# CF:
#   a(n) = n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+1
#
def naturals: #:: => *number
#   seq
    arithmetic(0; 1)
;

def positives: #:: => *number
#   seq(1)
    arithmetic(1; 1)
;

def negatives: #:: => *number
#   seq(-1;-1)
    arithmetic(-1; -1)
;

# CF:
#   a(n) = 2n+1
# RR:
#   a(0) = 1
#   a(n) = a(n-1)+2
#
def odds: #:: => *number
#   seq(1; 2)
    arithmetic(1; 2)
;

# CF:
#   a(n) = 2n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+2
#
def evens: #:: => *number
#   seq(0; 2)
    seq | .+.
;

# CF:
#   a(n) = d*n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+n
#
def multiples($n): #:: (number) => *number
#   seq(0; $n)
    arithmetic(0; $n)
;
def multiples: #:: number| => *number
#   seq(0; .)
    multiples(.)
;

# Geometric sequences ##################################################

# CF:
#   a(n) = a*r^n
# RR:
#   a(0) = a
#   a(n) = a(n-1)*r
#
def geometric($a; $r): #:: (number;number) => *number
    $a|recurse(. * $r)
;

# CF:
#   x(n) = r^n
# RR:
#   a(0) = 1
#   a(n) = a(n-1)*r
#
def powers($r): #:: (number) => *number
    geometric(1; $r)
;
def powers: #:: number| => *number
    powers(.)
;
def powers2: #:: => *number
    1|recurse(.+.)
;

# Other ################################################################

# CF:
#   a(n) = n^2; n*n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+2n-1
#
def squares: #:: => *number
#   seq | pow(.; 2)
#   seq | .*.
#   0 , foreach positives as $n (0; .+$n+$n-1)
    0,
    foreach odds as $n (0; .+$n)
;

# CF:
#   a(n) = n^3
# RR:
#   a(0) = 0
#   a(n) = n(a(n-1)+2n-1)
#
def cubes: #:: => *number
#   seq | pow(.; 3)
#   0 , foreach positives as $n (0; .+$n+$n-1; .*$n)
    foreach squares as $s (-1; .+1; . * $s)
;

#
def reciprocals(g): #:: (a->*number) => *number
    1/g
;

# CF:
#   a(n) = 1/n
#
def harmonic: #:: => *number
#   reciprocals(positives)
    1/positives
;

# CF:
#   a(n) = n%m
# RR:
#   a(0) = 0
#   a(n) = 0 if a(n-1)+1 = m else a(n-1)+1
#
def moduli($m): #:: (number) => *number
#   seq | (. % $m)
#   repeat(range(0; $m))
    0|recurse(.+1 | if . == $m then 0 end)
;
def moduli: #:: number| => *number
    moduli(.)
;

# RR:
#   a(0) = 1
#   a(n) = a(n-1)*n
#
def factorials: #:: => *number
#   1 , scan(.[0]*.[1]; 1; positives)
    1,
    foreach positives as $n (1; . * $n)
;

# RR:
#   a(0) = 0
#   a(n) = a(n-1)+n
#
def triangulars: #:: => *number
    0,
    foreach positives as $n (0; . + $n)
;

# RR:
#   a(0) = 0
#   a(1) = 1
#   a(n) = a(n-1) + a(n-2)
#
def fibonacci: #:: => *number
    0 , ([0,1] | unfold([.[-1] , [.[-1] , .[-1]+.[-2]]]))
#   [0,1]
#   | recurse([.[-1], .[-1]+.[-2]])
#   | .[-2]
;

# The famous sieve
#
#def primes: #:: => *number
#    def sieve(g):
#        first(g) as $n
#        | $n , sieve(g|select((. % $n) != 0))
#    ;
#    2 , sieve(3|recurse(.+2))
#;

# Very fast alternative!
def primes: #:: => *number
    def isprime(g):
        label $xit
        | g as $p
        | if . < ($p*$p)
          then true , break$xit
          elif (. % $p) == 0
          then false , break$xit
          else empty # next
          end
    ;
    2,
    (seq(3;2) | select(isprime(primes)))
;

# Number of bits equal to 1 in all naturals (number of ones)
#
# RR:
#   a(0) = 0
#   a(1) = 1
#   a(n+2^k) = a(n) + 1
# and
#   a(2n) = a(n)
#
def leibniz: #:: => *number
    def r(g): (g | .+1) , r(g , (g | .+1));
    0,
    1,
    r(0 , 1)
;

# Proper divisors ######################################################
#
# unordered
# Inspired in https://rosettacode.org/wiki/Proper_divisors#jq
def divisors($n):
    select($n > 1)
    | 1 , (range(2; 1+($n|sqrt|trunc)) as $i
            | select(($n % $i) == 0)
            | $i , (($n / $i) | select(. != $i)))
;

# without 1
def divisors1($n):
    select($n > 1)
    | range(2; 1+($n|sqrt|trunc)) as $i
    | select(($n % $i) == 0)
    | $i , (($n / $i) | select(. != $i))
;

# All integer partitions ###############################################
#
def partition($i): #:: (number) => *[number]
    def choose(a; b): range(a; 1+b);
    #
    def pmax(n; mx):
        if n == 0
        then []
        else
            choose(1; mx) as $m
            | (n-$m) as $k
            | fmin($k; $m) as $b
            | [$m]+pmax($k; $b)
        end
    ;
    pmax($i; $i)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
