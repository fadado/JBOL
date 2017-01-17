#!/usr/local/bin/jq -cnRrf

# Cut experiments

def found_coin(x):
    x==["LA",1,2] or
    x==["NY",1,1] or
    x==["BOS",2,2]
;

def find_boxes:
    ["LA", "NY", "BOS"][] as $city
    | label $cut
    | (1,2) as $store
    | (1,2) as $box
    | [$city, $store, $box]
    | if found_coin(.)
      then ., "--8<-------", break $cut
      else .
      end
;

def cut: error("8<");

def ifcut(v):
    if .=="8<" then v else error end
;

def find_boxes_X:
    ["LA", "NY", "BOS"][] as $city
    |try
          (1,2) as $store
        | (1,2) as $box
        | [$city, $store, $box] as $triple
        | if found_coin($triple)
          then $triple, cut
          else $triple
          end
     catch ifcut("--8<-------")
    ;

find_boxes,
"",
find_boxes_X

# vim:ai:sw=4:ts=4:et:syntax=jq
