#!/usr/local/bin/jq -cnRrf
#
# Determinar quins digits (0..9) poden substituir les lletres
# de l'expressió següent per fer-la certa:
#	SEND + MORE = MONEY

def num(a;b;c;d):
	a*1000+b*100+c*10+d
;
def num(a;b;c;d;e):
	a*10000+b*1000+c*100+d*10+e
;

def brute_force: # too slow
    def choose: range(0;10);
    label $fence
    | choose as $s | select($s > 0)
    | choose as $e
    | choose as $n
    | choose as $d
    | choose as $m | select($m > 0)
    | choose as $o
    | choose as $r
    | choose as $y
    | select(([$s,$e,$n,$d,$m,$o,$r,$y]|unique|length)==8)
    | select(num($s;$e;$n;$d) + num($m;$o;$r;$e) == num($m;$o;$n;$e;$y))
    | ([$s,$e,$n,$d,$m,$o,$r,$e,$m,$o,$n,$e,$y], break $fence)
;

def smart:
    def choose: range(0;10);
    label $fence
    | 1 as $m
    | 0 as $o
    | choose as $s | select($s > 7)
    | choose as $e
    | choose as $n
    | choose as $d
    | choose as $r
    | choose as $y
    | select(([$s,$e,$n,$d,$m,$o,$r,$y]|unique|length)==8)
    | select(num($s;$e;$n;$d) + num($m;$o;$r;$e) == num($m;$o;$n;$e;$y))
    | ([$s,$e,$n,$d,$m,$o,$r,$e,$m,$o,$n,$e,$y], break $fence)
;

def more_smart:
    def choose(m;n): range(m;n+1);
    label $fence
    | 1 as $m
    | 0 as $o
    | choose(8;9) as $s
    | choose(2;9) as $e
    | choose(2;9) as $n
    | choose(2;9) as $d
    | choose(2;9) as $r
    | choose(2;9) as $y
    | select(([$s,$e,$n,$d,$m,$o,$r,$y]|unique|length)==8)
    | select(num($s;$e;$n;$d) + num($m;$o;$r;$e) == num($m;$o;$n;$e;$y))
    | ([$s,$e,$n,$d,$m,$o,$r,$e,$m,$o,$n,$e,$y], break $fence)
;

def smartest:
    def choose(m;n;used): ([range(m;n+1)] - used)[];
    label $fence
    | 1 as $m
    | 0 as $o
    | choose(8;9;[]) as $s
    | choose(2;9;[$s]) as $e
    | choose(2;9;[$s,$e]) as $n
    | choose(2;9;[$s,$e,$n]) as $d
    | choose(2;9;[$s,$e,$n,$d]) as $r
    | choose(2;9;[$s,$e,$n,$d,$r]) as $y
    | select(num($s;$e;$n;$d) + num($m;$o;$r;$e) == num($m;$o;$n;$e;$y))
    | ([$s,$e,$n,$d,$m,$o,$r,$e,$m,$o,$n,$e,$y], break $fence)
;

now as $start | "Smartest:", smartest, (now - $start),
now as $start | "More smart:", more_smart, (now - $start),
now as $start | "Smart:", smart, (now - $start)
#now as $start | "Brute force:", brute_force, (now - $start)

# vim:ai:sw=4:ts=4:et:syntax=jq
