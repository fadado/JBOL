########################################################################
# Infinite series
########################################################################

include "lib/control";

def from(n):
# 1.
#   def R: ., (. + 1 | R);
#   n | R
# 2.
    n | iterate(.+1)
;

def fromBy(n; $i):
# 1.
#   def R: ., (. + $i | R);
#   n | R
# 2.
    n | iterate(.+$i)
;

def factorial:
# 1.
#   def R:
#       (.n + 1) as $n |
#       (.f * $n) as $f |
#       .f, ({n: $n, f: $f} | R);
#   {n: 0, f: 1} | R
# 2.
#   {n: 0, f: 1}
#   | iterate({n: (.n+1), f: (.f*(.n+1))})
#   | .f
# 3.
    1, foreach from(0) as $i (1; . * ($i+1); .)
;

def fibonacci:
# 1.
#   def R:
#       (.x + .y) as $f |
#       $f, ({x: .y, y: $f} | R);
#   {x: -1, y: 1} | R
# 2.
    {x: -1, y: 1}
    | iterate({x: .y, y: (.x+.y)})
    | (.x+.y)
;

def powers($n):
# 1.
#   def R: ., (. * $n | R);
#   1 | R
# 2.
#   1 | iterate(.*$n)
# 3.
#   1, $n, foreach from(0) as $_ ($n; . * $n; .)
# 4. 9007199254740992 = 2^53
    1, foreach range(9007199254740992) as $_ (1; . * $n; .)
;

# vim:ai:sw=4:ts=4:et:syntax=python
