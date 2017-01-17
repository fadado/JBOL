#!/usr/local/bin/jq -nf

include "fadado.github.io/prelude";
include "fadado.github.io/string";

([range(32),127]|implode) as $cntrl             |
" \t\r\n\f\u000b " as $space                    |
" \t " as $blank                                |
"ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝÞÐ___" as $upper |
"abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïñòóôõöøùúûüýþ_ÿßð" as $lower |
($lower+$upper) as $alpha                       |
($upper+$lower) as $ALPHA                       |
"0123456789" as $digit                          |
($alpha+$digit) as $alnum                       |
($digit+"abcdefABCDEF") as $xdigit              |
"(<)=[*>\\!+?]{\",@^|#-_}$.`~%/&:';¡¢£¤¥¦§¨©ª«­®¯°´µ¶¸º»¿¬±×÷¼½¾¹²³" as $punct |
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
    "iscntrl":  set($cntrl),
    "isspace":  set($space),
    "isupper":  set($upper),
    "islower":  set($lower),
    "isdigit":  set($digit),
    "isxdigit": set($xdigit),
    "ispunct":  set($punct),
#   "isblank":  set($blank),
#   "isalpha":  set($alpha),
#   "isalnum":  set($alnum),
#   "isgraph":  set($graph),
#   "isprint":  set($print),

# translation tables
    "tolower":  table($upper; $lower),
    "toupper":  table($lower; $upper),
}

# vim:ai:sw=4:ts=4:et:syntax=jq
