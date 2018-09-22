module {
    name: "json",
    description: "JSON utilities",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/types";
import "fadado.github.io/string/ascii" as ascii;

# Is JQ syntactic identifier?
def isid: #:: string => boolean
   length > 0
   and ascii::isword
   and (.[0:1] | false==ascii::isdigit)
;
def isid($s): #:: string => boolean
    $s | isid
;

def _xtok: #:: string => number
    "[_:A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\\x{00010000}-\\x{000EFFFF}]"
        as $NameStartChar |
    ("(:?"+$NameStartChar+"|"+"[-.·0-9\u0300-\u036F\u203F-\u2040])")
        as $NameChar |
    ("^"+$NameChar+"+"+"$")
        as $Nmtoken |
#   ("^"+$NameStartChar+$NameChar+"*"+"$") as $Name |
    if test($Nmtoken)
    then if test("^"+$NameStartChar) then 1 else 2 end
    else 0
    end
;

def xname: #:: string => boolean
    _xtok == 1
;
def xname($s): #:: (string) => boolean
    $s | _xtok == 1
;

def xtoken: #:: string => boolean
    _xtok == 2
;
def xtoken($s): #:: (string) => boolean
    $s | _xtok == 2
;

#
def xmldoc($root; $item; $tab; $doctype): #:: JSON|(string;string;string;string^null) => XML
    def toxml($name; $margin):
        if isnull
        then "\($margin)<\($name) json:type='null'/>"
        elif isboolean or isnumber or isstring
        then "\($margin)<\($name) json:type='\(type)'>\(.)</\($name)>"
        elif isarray
        then 
            if length==0 then
                "\($margin)<\($name) json:type='array'/>"
            else
                "\($margin)<\($name) json:type='array'>",
                (.[] | toxml($item; $margin+$tab)),
                "\($margin)</\($name)>"
            end
        else # isobject
            if length==0 then
                "\($margin)<\($name) json:type='object'/>"
            else
                "\($margin)<\($name) json:type='object'>",
                (keys_unsorted[] as $k | .[$k] | toxml($k; $margin+$tab)),
                "\($margin)</\($name)>"
            end
        end
    ;
    "xmlns:json='https://github.com/fadado/JBOL'" as $xmlns |
    "<?xml version='1.0' encoding='utf-8' standalone='yes'?>",
    $doctype//empty,
    if isnull
    then "<json:\($root) \($xmlns) json:type='null'/>"
    elif isboolean or isnumber or isstring
    then "<json:\($root) \($xmlns) json:type='\(type)'>\(.)</json:\($root)>"
    elif isarray
    then 
        if length==0 then
            "<json:\($root) \($xmlns) json:type='array'/>"
        else
            "<json:\($root) \($xmlns) json:type='array'>",
            (.[] | toxml($item; $tab)),
            "</json:\($root)>"
        end
    else # isobject
        if length==0 then
            "<json:\($root) \($xmlns) json:type='object'/>"
        else
            "<json:\($root) \($xmlns) json:type='object'>",
            (keys_unsorted[] as $k | .[$k] | toxml($k; $tab)),
            "</json:\($root)>"
        end
    end
;

def xmldoc: #:: JSON => XML
    xmldoc("document"; "element"; "  "; null)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
