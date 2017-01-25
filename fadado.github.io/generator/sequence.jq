module {
    name: "sequence",
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
#   a(0) = a
#   a(n) = a(n-1)+d
#
def arithmetic($a; $d): #:: (number;number) -> <number>
    $a|iterate(.+$d) # range($a; infinite; $d)
;

# CF:
#   a(n) = n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+1
#
def naturals: #:: -> <number>
    arithmetic(0; 1) # range(0; infinite; 1)
;

def positives: #:: -> <number>
    arithmetic(1; 1) # range(1; infinite; 1)
;

def negatives: #:: -> <number>
    arithmetic(-1; -1) # range(-1; -(infinite); -1)
;

#def seq($a; $d): #:: (number;$number) -> <number>
#    arithmetic($a; $d) # range($a; infinite; $d)
#;
#def seq($a): #:: (number) -> <number>
#    arithmetic($a; 1) # range($a; infinite; 1)
#;
#def seq: #:: -> <number>
#    arithmetic(0; 1) # range(1; infinite; 1)
#;
#def to($m; $n): #:: (number;number) -> <number>
#    label $exit # range($m; $n+1)
#    | arithmetic($m; 1)
#    | if . <= $n
#      then .
#      else break $exit
#      end
#;

# CF:
#   a(n) = 2n+1
# RR:
#   a(0) = 1
#   a(n) = a(n-1)+2
#
def odds: #:: -> <number>
    arithmetic(1; 2) # range(1; infinite; 2)
;

# CF:
#   a(n) = 2n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+2
#
def evens: #:: -> <number>
    arithmetic(0; 2) # range(0; infinite; 2)
;

# CF:
#   a(n) = d*n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+n
#
def multiples($n): #:: (number) -> <number>
    arithmetic(0; $n) # range(0; infinite; $n)
;
def multiples: #:: number| -> <number>
    multiples(.) # range(0; infinite; .)
;

# Geometric sequences ##################################################

# CF:
#   a(n) = a*r^n
# RR:
#   a(0) = a
#   a(n) = a(n-1)*r
#
def geometric($a; $r): #:: (number;number) -> <number>
    $a|iterate(.*$r)
;

# CF:
#   x(n) = r^n
# RR:
#   a(0) = 1
#   a(n) = a(n-1)*r
#
def powers($r): #:: (number) -> <number>
    geometric(1; $r)
;
def powers: #:: number| -> <number>
    powers(.)
;

# Other ################################################################

# CF:
#   a(n) = n^2
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+2n-1
#
def squares: #:: -> <number>
    0, foreach odds as $n (0; .+$n)
#   0, foreach positives as $n (0; .+$n+$n-1)
#   tabulate(pow(.; 2))
;

# CF:
#   a(n) = n^3
# RR:
#   a(0) = 0
#   a(n) = n(a(n-1)+2n-1)
#
def cubes: #:: -> <number>
    foreach squares as $s (-1; .+1; $s*.)
#   0, foreach positives as $n (0; .+$n+$n-1; .*$n)
#   tabulate(pow(.; 3))
;

#
def reciprocals(g): #:: (<number>)-> <number>
    g | 1/.
;

# CF:
#   a(n) = 1/n
#
def harmonic: #:: -> <number>
    reciprocals(positives)
;

# CF:
#   a(n) = n%m
# RR:
#   a(0) = 0
#   a(n) = 0 if a(n-1)+1 = m else a(n-1)+1
#
def modules($m): #:: (number)-> <number>
    0|iterate(.+1|when(. == $m; 0))
#   repeat(range(0; $m))
#   tabulate(.%$m)
;
def modules: #:: number| -> <number>
    modules(.)
;

# RR:
#   a(0) = 1
#   a(n) = a(n-1)*n
#
def factorials: #:: -> <number>
    1, foreach positives as $n (1; .*$n)
#   1, scan(.[0]*.[1]; 1; positives)
;

# RR:
#   a(0) = 0
#   a(n) = a(n-1)+n
#
def triangulars: #:: -> <number>
    0, foreach positives as $n (0; .+$n)
;

# RR:
#   a(0) = 0
#   a(1) = 1
#   a(n) = a(n-1) + a(n-2)
#
def fibonacci: #:: -> <number>
    [0,1]
    | iterate([.[-1], .[-1]+.[-2]])
    | .[-2]
#   0, ([0,1] | unfold([.[-1], [.[-1], .[-2]+.[-1]]]))
;

# Fibbonacci strings
def fibstr($s; $t): #:: (string;string) -> <number>
    [$s,$t]
    | iterate([.[-1], .[-1]+.[-2]])
    | .[-2]
;
def fibstr: #:: -> <number>
    fibstr("a"; "b")
;

# The famous sieve
#
def primes: #:: -> <number>
    def sieve(g): #:: (<number>) -> <number>
        # first(g) as $n
        (label $pipe | g | . , break $pipe) as $n
        | $n, sieve(g|select((. % $n) != 0))
    ;
    sieve(range(2; infinite))
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
def leibniz: #:: -> <number>
    def r(g): (g|.+1), r(g , (g|.+1));
    0, 1,  r(0 , 1)
;

# All integer partitions ###############################################
#
def partition($i): #:: (number) -> <[number]>
	def choose(a; b): range(a; 1+b);
    #
	def pmax(n; mx):
		if n == 0
		then []
		else
			choose(1; mx) as $m
			| (n-$m) as $k
			| min($k; $m) as $b
			| [$m]+pmax($k; $b)
		end
	;
	pmax($i; $i)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
