module {
    name: "math/bitwise",
    description: "Bitwise operations on numbers",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

########################################################################
# Bitwise operations

# BIT:      2^0..2^52
# POSITION: 0..52

########################################################################
# Low level private functions
########################################################################

def _bit($position): #:: (POSITION) => BIT
    $position|exp2
;

def _pos($bit): #:: (BIT) => POSITION
    $bit|log2
;

def _test($bit; $n): #:: (BIT;number) => boolean
    $n/$bit | floor%2 != 0
;

def _mask($size): #:: (number) => number
    ($size|exp2) - 1
;

def _flip: #:: number| => number
    def r($x; $result; $pow2):
        if $x < 1
        then $result
        elif $x%2==0
        then r($x/2|floor; $result+$pow2; $pow2*2) 
        else r($x/2|floor; $result; $pow2*2) 
        end
    ;
    if .==0 then 1 else r(.; 0; 1) end
;

########################################################################
# Bitset operations
########################################################################

def getbit($position; $n): #:: (POSITION;number) => 0^1
#   if _test(_bit($position); $n) then 1 else 0 end
    $n/_bit($position) | floor%2 | fabs
;

def setbit($position; $n): #:: (POSITION;number) => number
    _bit($position) as $bit
    | if _test($bit; $n)
    then $n
    else $n + $bit
    end
;

def clrbit($position; $n): #:: (POSITION;number) => number
    _bit($position) as $bit
    | if  _test($bit; $n)
    then $n - $bit
    else $n
    end
;

########################################################################
# Common LISP imported functions
########################################################################

def ash($count; $n): #:: (number;number) => number
#   $n * ($count|exp2) | floor
    ldexp($n; $count) | floor
;

def integer_length($n): #:: (number) => number
    if $n < 0 then -$n else $n+1 end
    | log2 | ceil
;

def lognot($n): #:: (number) => number
    -1 - $n
;

def logand($m; $n): #:: (number;number) => number
    def r($x; $y; $result; $pow2):
        if $x < 1 or $y < 1
        then $result
        elif ($x%2!=0) and ($y%2!=0)
        then r($x/2|floor; $y/2|floor; $result+$pow2; $pow2*2) 
        else r($x/2|floor; $y/2|floor; $result; $pow2*2) 
        end
    ;
    r($m; $n; 0; 1)
;

def logior($m; $n): #:: (number;number) => number
    def r($x; $y; $result; $pow2):
        if $x < 1 and $y < 1
        then $result
        elif ($x%2!=0) or ($y%2!=0)
        then r($x/2|floor; $y/2|floor; $result+$pow2; $pow2*2) 
        else r($x/2|floor; $y/2|floor; $result; $pow2*2) 
        end
    ;
    r($m; $n; 0; 1)
;

def logxor($m; $n): #:: (number;number) => number
    def r($x; $y; $result; $pow2):
        if $x < 1 and $y < 1
        then $result
        elif ($x%2!=0) != ($y%2!=0)
        then r($x/2|floor; $y/2|floor; $result+$pow2; $pow2*2) 
        else r($x/2|floor; $y/2|floor; $result; $pow2*2) 
        end
    ;
    r($m; $n; 0; 1)
;

def logeqv($m; $n): #:: (number;number) => number
    logxor($m; $n)|_flip
;

def lognand($m; $n): #:: (number;number) => number
    logand($m; $n)|_flip
;

def lognor($m; $n): #:: (number;number) => number
    logior($m; $n)|_flip
;

def logandc1($m; $n): #:: (number;number) => number
    logand($m|_flip; $n)
;

def logandc2($m; $n): #:: (number;number) => number
    logand($m; $n|_flip)
;

def logorc1($m; $n): #:: (number;number) => number
    logior($m|_flip; $n)
;

def logorc2($m; $n): #:: (number;number) => number
    logior($m; $n|_flip)
;

def logtest($m; $n): #:: (number;number) => boolean
    logand($m; $n) != 0
;

def logbitp($position; $n): #:: (POSITION;number) => boolean
    _test(_bit($position); $n)
;

def logcount($n): #:: (number) => number
    def r($x; $result):
        if $x < 1
        then $result
        elif $x%2!= 0
        then r($x/2|floor; $result+1)
        else r($x/2|floor; $result)
        end
    ;
    r($n; 0)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
