module {
    name: "string/regexp",
    description: "Pattern matching using regular expressions",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";
import "fadado.github.io/string" as str;

########################################################################
# Module based on builtin `_match_impl`.
#
# `match` outputs an object for each match it finds. Matches have the following
# fields:
#
# offset   - offset in UTF-8 codepoints from the beginning of the input
# length   - length in UTF-8 codepoints of the match
# string   - the string that it matched
# captures - an array of objects representing capturing groups.
#
# Capturing group objects have the following fields:
#
# offset - offset in UTF-8 codepoints from the beginning of the input
# length - length in UTF-8 codepoints of this capturing group
# string - the string that was captured
# name   - the name of the capturing group (or null if it was unnamed)
#
# Capturing groups that did not match anything return an offset of -1.
########################################################################

########################################################################
# Simulating scanf
#
# scanf() Token     Regular Expression
# %c                "."
# %5c               ".{5}"
# %d                "[-+]?\\d+"
# %e, %E, %f, %g    "[-+]?(\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?"
# %i                "[-+]?(0[xX][\\dA-Fa-f]+|0[0-7]*|\\d+)"
# %o                "[-+]?[0-7]+"
# %s                "\\S+"
# %u                "\\d+"
# %x, %X            "[-+]?(0[xX])?[\\dA-Fa-f]+"
########################################################################

########################################################################
# Copy of builtin `test`
#
# Only to provide all pattern matching services in this module.
#
def test($regex; $flags): #:: string|(string;string) => boolean
    _match_impl($regex; $flags; true)
;
def test($regex): #:: string|(string) => boolean
    _match_impl($regex; null; true)
;

########################################################################
# Enhanced match
#
# Like builtin `match` but add to the match object some strings for context
# (like Perl $`, $& and $').
#
def match($regex; $flags): #:: string|(string;string) => *MATCH
    . as $subject
    | _match_impl($regex; $flags; false)[]
    | . + { "&": .string,
            "`": $subject[:.offset],
            "'": $subject[.offset+.length:] }
;

def match($regex): #:: string|(string) => *MATCH
    match($regex; "")
;

########################################################################
# Some filters to use instead of `capture` and `scan`. Typical usage:
#   match(re; m)  | tomap as $d ...
#   match(re; m)  | tolist as $a ...
#   match(re; m)  | tostr as $a ...

# Extract named groups from a MATCH object as a map (object)
#
def tomap: #:: MATCH| => {string}
    def init:
        if ."&" == null
        then {}
        else {"&":."&", "`":."`", "'":."'"}
        end
    ;
    reduce (.captures[]
            | select(.name != null)
            | {(.name):.string})
        as $pair
        (init; . + $pair)
;

# Extract matched string and all groups from a MATCH object as a list (array)
#
def tolist: #:: MATCH| => [string]
    [.string, (.captures[] | .string)]
;

# Extract matched string or first non null group from a MATCH object
#
def tostr: #:: MATCH| => string
    (.captures|length) as $len
    | if $len == 0
      then .string
      else 
        label $fence
        | range(0;$len) as $i
        | select(.captures[$i].string) # not null
        | (.captures[$i].string , break $fence)
      end
      // ""
;

########################################################################
# Enhanced substitutes for `split` and `splits` builtins
#
#   * Emit 1..$limit items
#   * Include matched groups if present

def split($regex; $flags; $limit): #:: string|(string;string;number) => *string
    def nwise: # n = 3
        when(length > 3;
             .[0:3] , (.[3:] | nwise))
    ;
    if $limit < 0
    then empty
    elif $limit == 0 or $regex == ""
    then .
    else
        . as $subject
        | [ 0, # first index
            (label $loop
                | foreach match($regex; $flags+"g") as $m
                    ($limit; .-1; # init; update;
                     # yield if conditions are ok
                     if . < 0
                     then break$loop
                     else $m.offset, $m.captures, $m.offset+$m.length
                     end)),
            ($subject|length), # last index
            [] # empty captures for last segment
        ]
        | nwise as [$i, $j, $groups]
        | $subject[$i:$j], ($groups[] | .string)
    end
;

# Fully compatible with `splits/2`, and replaces `split/2` in a non compatible
# way (use [regexp::split(r;f)] for compatible behavior)
#
def split($regex; $a): #:: string|(string;number^string) => *string
    if $a|isnumber
    then split($regex; ""; $a)     # $a = limit
    elif $a|isstring
    then split($regex; $a; infinite) # $a = flags
    else $a|typerror("number or string")
    end
;

# Fully compatible with `splits/1`, and replaces `split/1` in a non compatible
# way (use "s"/"d" instead for full compatibility)
#
def split($regex): #:: string|(string) => *string
    split($regex; "g"; infinite)
;

# Splits its input on white space breaks, trimming space around
#
def split: #:: string| => *string
    str::trim | split("\\s+"; ""; infinite)
;

########################################################################
# Compatible substitutes for `sub` and `gsub` builtins

def sub($regex; template; $flags): #:: string|(string;string;string) => string
    def sub1($flags; $gs):
        def _sub1:
            . as $subject
            | [match($regex; $flags)] # only one match (or empty)
            | if length == 0
              then $subject
              else
                .[0] as $m
                | reduce ($m.captures[]
                          | select(.name != null)
                          | {(.name):.string})
                    as $pair
                    ({"&":$m."&", "`":$m."`", "'":$m."'"}; .+$pair)
                | template as $replacement # expands template with \(...)
                | $subject[0:$m.offset]
                    + $replacement
                    + ($subject[$m.offset+$m.length:]
                       | if $gs and length > 0 then _sub1 else . end)
              end
        ;
        _sub1
    ;
    ($flags|contains("g")) as $gs
    | ($flags | when($gs; mapstr(select(.!="g")))) as $fs
    | sub1($fs; $gs)
;

def sub($regex; template): #:: string|(string;string) => string
    sub($regex; template; "")
;

def gsub($regex; template; $flags): #:: string|(string;string;string) => string
    sub($regex; template; $flags+"g")
;

def gsub($regex; template): #:: string|(string;string) => string
    sub($regex; template; "g")
;

# vim:ai:sw=4:ts=4:et:syntax=jq
