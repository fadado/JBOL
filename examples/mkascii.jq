#!/usr/local/bin/jq -nf

include "fadado.github.io/prelude";
include "fadado.github.io/string";
import "fadado.github.io/string/table" as table;
import "fadado.github.io/object/set" as set;

([range(32),127]|implode) as $cntrl             |
" \t\r\n\f\u000b" as $space                     |
" \t" as $blank                                 |
"ABCDEFGHIJKLMNOPQRSTUVWXYZ" as $upper          |
"abcdefghijklmnopqrstuvwxyz" as $lower          |
($lower+$upper) as $alpha                       |
($upper+$lower) as $ALPHA                       |
"0123456789" as $digit                          |
($alpha+$digit) as $alnum                       |
($digit+"abcdefABCDEF") as $xdigit              |
"(<)=[*>\\!+?]{\",@^|#-_}$.`~%/&:';" as $punct  |
($upper+$lower+$digit+$punct) as $graph         |
($blank+$graph) as $print                       |

{
# strings
    "cntrl":  $cntrl,
    "space":  $space,
    "blank":  $blank,
    "upper":  $upper,
    "lower":  $lower,
    "alpha":  $alpha,
    "ALPHA":  $ALPHA,
    "digit":  $digit,
    "xdigit": $xdigit,
    "punct":  $punct,
    "alnum":  $alnum,
    "graph":  $graph,
    "print":  $print,

# character sets
    "iscntrl":  set::new($cntrl),
    "isspace":  set::new($space),
    "isupper":  set::new($upper),
    "islower":  set::new($lower),
    "isdigit":  set::new($digit),
    "isxdigit": set::new($xdigit),
    "ispunct":  set::new($punct),
#   "isblank":  set::new($blank),
#   "isalpha":  set::new($alpha),
#   "isalnum":  set::new($alnum),
#   "isgraph":  set::new($graph),
#   "isprint":  set::new($print),

# translation tables
    "tolower":  table::new($upper; $lower),
    "toupper":  table::new($lower; $upper),
}

# vim:ai:sw=4:ts=4:et:syntax=jq
