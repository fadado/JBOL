#!/usr/local/bin/jq -cnRrf

import "fadado.github.io/word/scanner" as scan;
import "fadado.github.io/string/ascii" as ascii;

def isid:
   length > 0
   and scan::many("_"+ascii::alnum) == length
   and scan::g_sym(false==ascii::isdigit)
   // false
;
def isid($s):
    $s | isid
;

isid("Label33"),
isid("1Label33"),
isid("  Label33")

# vim:ai:sw=4:ts=4:et:syntax=jq
