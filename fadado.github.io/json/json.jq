module {
    name: "json",
    description: "JSON utilities",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

import "fadado.github.io/word/scanner" as scan;
import "fadado.github.io/string/ascii" as ascii;

def isid:
   length > 0
   and scan::many("_"+ascii::alnum)==length
   and scan::g_sym(false==ascii::isdigit)
   // false
;
def isid($s):
    $s | isid
;

# vim:ai:sw=4:ts=4:et:syntax=jq
