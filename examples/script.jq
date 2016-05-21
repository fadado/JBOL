# Called from `script.sh`

# Produces a stream on positions of `needle` inside `haystack`
def find(needle; haystack):
    haystack | _strindices(needle)[]
;

# Entry point
def main:
    "Positions of \"" + $string + "\" inside \"" + $target + "\":",
   find($string; $target)
;

main

# vim:ai:sw=4:ts=4:et:syntax=python
