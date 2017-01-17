#!/usr/local/bin/jq -cnRrf

# SNOBOL like experiments

include "fadado.github.io/prelude";
include "fadado.github.io/string/snobol";

def example1:
    def pattern:
        # "(B|R)(E|EA)(D|DS)"
        label $found
        | (L("B"), L("R"))
        | (L("E"), L("EA"))
        | (L("D"), L("DS"))
        | ., break $found
   ;
   A("READS") | pattern
;

def example2:
    def pattern:
        # "(BUG|LITTLE)
        label $found
        | (L("BIG"), L("LITTLE"))
        | ., break $found
   ;
   U("A BIG BOY") | pattern
;

def example3:
    def pattern:
        # "(B|R)(E|EA)(D|DS)"
        label $found
        | (L("B"), L("R"))  | AT as $i
        | (L("E"), L("EA")) | AT as $j
        | (L("D"), L("DS")) | AT as $k
        | [$i, $j, $k],
          break $found
   ;
   A("READS") | pattern
;

def example4:
    def pattern:
        # "(B|R)(E|EA)(D|DS)"
        label $found
        | (L("B"), L("R"))  | M as $left
        | (L("E"), L("EA")) | REM | M as $right
        | (L("D"), L("DS"))
        | ($left + "I" + $right),
          break $found
   ;
   [ (A("BED")   | pattern),
     (A("BEAD")  | pattern),
     (A("BEDS")  | pattern),
     (A("BEADS") | pattern) ]
;

def example5:
    def pattern:
        # "((BE|BEA|BEAR)(DS|D))((RO|ROO|ROOS)(TS|T))"
        label $found
        | ((L("BE"), L("BEA"), L("BEAR")) | (L("DS"), L("D")))
        , ((L("RO"), L("ROO"), L("ROOS")) | (L("T"), L("TS")))
        | ., break $found
    ;
    every(
        success(A("BEDS")   | pattern),
        success(A("BED")    | pattern),
        success(A("BEADS")  | pattern),
        success(A("BEDS")   | pattern),
        success(A("BEARDS") | pattern),
        success(A("BEARD")  | pattern),
        success(A("ROTS")   | pattern),
        success(A("ROT")    | pattern),
        success(A("ROOTS")  | pattern),
        success(A("ROOT")   | pattern),
        success(A("ROOSTS") | pattern),
        success(A("ROOST")  | pattern)
    )
;

########################################################################
#

"",
1,example1 == {"s":"READS","i":0, "j":4, },
2,example2 == {"s":"A BIG BOY","i":2,"j":5},
3,example3 == [1,3,4],
4,example4 == ["BID","BID","BIDS","BIDS"],
5,example5 == true,
""

# vim:ai:sw=4:ts=4:et:syntax=jq
