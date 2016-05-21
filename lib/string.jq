########################################################################
# String functions
########################################################################

# Generates the stream of integer positions in `haystack` at which `needle`
# inside `haystack` occurs as a substring, or `empty` if there is no such
# position
def find(needle; haystack):
    haystack | _strindices(needle)[]
;

# Generates the stream of integer positions in `string` preceding a character
# of `cset`, or `empty` if there is no such position
def upto(cset; string):
    string
    | [_strindices((cset/"")[])]
    | flatten
    | unique[]
;

# Produces an integer (ordinal) that is the internal representation of the
# first character in `s`
def ord(s):
    s | explode[0]
;

# Produces a string of length 1 consisting of the character whose internal
# representation is `n`
def chr(n):
    [n] | implode
;

# vim:ai:sw=4:ts=4:et:syntax=python
