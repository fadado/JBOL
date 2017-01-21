#!/usr/local/bin/jq -cnrf

100 as $N
| range(1; 1+$N) as $a
| range($a+1; 1+$N) as $b
| range($b+1; 1+$N) as $c
| if $a*$a+$b*$b==$c*$c
  then .
  else empty end
| [$a,$b,$c]

# vim:ai:sw=4:ts=4:et:syntax=jq
