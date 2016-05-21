#!/usr/bin/jq -nRrf

# Usage:
#   ./cross.jq --arg word1 'lottery' --arg word2 'boat'
#   ./cross.jq --arg word1 'computer' --arg word2 'center'
#
# Output:
#  b
# lottery
#  a
#  t
# 
#   b
#   o
#   a
# lottery
# 
#    b
#    o
#    a
# lottery
# 

# Produces a stream of positions of `cset` characters inside `string`
def upto(cset; string):
    string
    | [_strindices((cset/"")[])]
    | flatten
    | unique[]
;

# Produces a stream of intersections between two words
def cross($w1; $w2):
    upto($w2; $w1) as $i |
    upto($w1[$i:1+$i]; $w2) as $j |
    [ (($w2[0:$j]/"")[] | (" "*$i) + .),
      $w1,
      (($w2[$j+1:]/"")[] | (" "*$i) + .) ]
;

# Entry point
def main:
    cross($word1; $word2) | .[], ""
;

main

# vim:ai:sw=4:ts=4:et:syntax=python
