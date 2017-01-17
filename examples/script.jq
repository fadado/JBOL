#!/usr/local/bin/jq -cnrf

include "fadado.github.io/string";

# Entry point
def main($string; $subject):
   "Positions of \"" + $string + "\" inside \"" + $subject + "\":",
   ($subject|indices($string)[])
;

main("on";"one motion is optional")

# vim:ai:sw=4:ts=4:et:syntax=jq
