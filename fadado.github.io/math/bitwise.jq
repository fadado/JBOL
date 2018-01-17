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

# BitField: 0..(2^53-1) (53 bits unsigned integer)
# Bit:      2^0, 2^1, 2^2, ...2^52
# Position: 0..52

########################################################################
# Low level private functions
########################################################################

def _mask($size): $size|exp2-1;

#def _bit($position): $position|exp2;
#def _pos($bit): $bit|log2;

########################################################################
# Common LISP borrowed functions
#
# CLTL: 12.7. Logical Operations on Numbers
#       http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node131.html
########################################################################

# See: http://clhs.lisp.se/Body/f_logand.htm
def lognot($n): #:: (BitField) => BitField
    9007199254740991 - $n # use precalculated constant (53|exp2)-1
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def logand($m; $n): #:: (BitField;BitField) => BitField
    def r($x; $y; $result; $pow2):
        if $x < 1 or $y < 1
        then $result
        elif fmod($x;2)!=0 and fmod($y;2)!=0
        then r($x/2|floor; $y/2|floor; $result+$pow2; $pow2*2) 
        else r($x/2|floor; $y/2|floor; $result; $pow2*2) 
        end
    ;
    r($m; $n; 0e0; 1)
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def logior($m; $n): #:: (BitField;BitField) => BitField
    def r($x; $y; $result; $pow2):
        if $x < 1 and $y < 1
        then $result
        elif fmod($x;2)!=0 or fmod($y;2)!=0
        then r($x/2|floor; $y/2|floor; $result+$pow2; $pow2*2) 
        else r($x/2|floor; $y/2|floor; $result; $pow2*2) 
        end
    ;
    r($m; $n; 0e0; 1)
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def logxor($m; $n): #:: (BitField;BitField) => BitField
    def r($x; $y; $result; $pow2):
        if $x < 1 and $y < 1
        then $result
        elif (fmod($x;2)!=0) != (fmod($y;2)!=0)
        then r($x/2|floor; $y/2|floor; $result+$pow2; $pow2*2) 
        else r($x/2|floor; $y/2|floor; $result; $pow2*2) 
        end
    ;
    r($m; $n; 0e0; 1)
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def logeqv($m; $n): #:: (BitField;BitField) => BitField
    lognot(logxor($m; $n))
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def lognand($m; $n): #:: (BitField;BitField) => BitField
    lognot(logand($m; $n))
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def lognor($m; $n): #:: (BitField;BitField) => BitField
    lognot(logior($m; $n))
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def logandc1($m; $n): #:: (BitField;BitField) => BitField
    logand(lognot($m); $n)
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def logandc2($m; $n): #:: (BitField;BitField) => BitField
    logand($m; lognot($n))
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def logorc1($m; $n): #:: (BitField;BitField) => BitField
    logior(lognot($m); $n)
;

# See: http://clhs.lisp.se/Body/f_logand.htm
def logorc2($m; $n): #:: (BitField;BitField) => BitField
    logior($m; lognot($n))
;

# See: http://clhs.lisp.se/Body/f_logtes.htm
def logtest($m; $n): #:: (BitField;BitField) => boolean
    logand($m; $n) != 0e0
;

# See: http://clhs.lisp.se/Body/f_logbtp.htm
def logbitp($position; $n): #:: (Position;BitField) => boolean
    fmod($n/($position|exp2)|floor;2) != 0
;

# See: http://clhs.lisp.se/Body/f_ash.htm
def ash($count; $n): #:: (number;BitField) => BitField
    $n*($count|exp2)|floor
;

# See: http://clhs.lisp.se/Body/f_intege.htm
def integer_length($n): #:: (BitField) => number
    if $n < 0 then -$n else $n+1 end
    | log2 | ceil
;

# See: http://clhs.lisp.se/Body/f_logcou.htm
def logcount($n): #:: (BitField) => number
    def r($x; $result):
        if $x < 1
        then $result
        elif fmod($x;2) != 0
        then r($x/2|floor; $result+1)
        else r($x/2|floor; $result)
        end
    ;
    r($n; 0)
;

########################################################################
# Common LISP borrowed functions
#
# CLTL 12.8. Byte Manipulation Functions
#       http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node132.html
########################################################################

def byte($size; $position):
    {
        $size,
        $position,
        mask: ash($position; _mask($size))
    }
;

def byte_size($bytespec):
    $bytespec.size
;

def byte_position($bytespec):
    $bytespec.position
;

def ldb($bytespec; $n):
    logand($bytespec.mask; $n) as $b
    | ash(-$bytespec.position; $b)
;

def ldb_test($bytespec; $n):
    logand($bytespec.mask; $n) != 0
;

def mask_field($bytespec; $n):
    logand($bytespec.mask; $n)
;

def dpb($newbyte; $bytespec; $n):
    logand(lognot($bytespec.mask); $n) $m
    | logand($bytespec.mask; ash($bytespec.position; $newbyte);) as $b
    | logior($b; $m)
;

def deposit_field($newbyte; $bytespec; $n):
    logand(lognot($bytespec.mask); $n) $m
    | logand($bytespec.mask; $newbyte) as $b
    | logior($b; $m)
;

########################################################################
# Bitset operations, not borrowed from LISP
########################################################################

# New empty bitset: 0e0

# Set bit at $position
def setbit($position; $n): #:: (Position;BitField) => BitField
    if fmod($n/($position|exp2)|floor;2) != 0
    then $n
    else $n + ($position|exp2)
    end
;

# Clear bit at $position
def clrbit($position; $n): #:: (Position;BitField) => BitField
    if fmod($n/($position|exp2)|floor;2) != 0
    then $n - ($position|exp2)
    else $n
    end
;

# Toggle bit at $position
def tglbit($position; $n): #:: (Position;BitField) => BitField
    if fmod($n/($position|exp2)|floor;2) != 0
    then $n - ($position|exp2)
    else $n + ($position|exp2)
    end
;

# Get bit at $position as 0 or 1
def getbit($position; $n): #:: (Position;BitField) => 0^1
    fmod($n/($position|exp2)|floor;2) | fabs
;

# vim:ai:sw=4:ts=4:et:syntax=jq
