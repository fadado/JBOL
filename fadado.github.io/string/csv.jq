module {
    name: "string/csv",
    description: "Comma Separated Values scanner",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

# From: https://tools.ietf.org/html/rfc4180
#
# file = [header CRLF] record *(CRLF record) [CRLF]
# header = name *(COMMA name)
# record = field *(COMMA field)
# name = field
# field = (escaped / non-escaped)
# escaped = DQUOTE *(TEXTDATA / COMMA / CR / LF / 2DQUOTE) DQUOTE
# non-escaped = *TEXTDATA
# COMMA = %x2C
# CR = %x0D
# DQUOTE =  %x22
# LF = %x0A
# CRLF = CR LF
# TEXTDATA =  %x20-21 / %x23-2B / %x2D-7E

def fromcsv: # . is a record
    def csv($str; $len):
        # combinators (primitive: `|`, `,`, `recurse`: sequence, alternate and Kleene*)
        def plus(scanner): scanner | recurse(scanner); # Kleene+
        def optional(scanner): first(scanner , .);
        # scanners: position -> position
        def char(test): select(. < $len and ($str[.:.+1] | test)) | .+1; 
        def many($alphabet): select(. < $len) | last(plus(char(inside($alphabet)))) // empty;
        def CR: char(. == "\r");
        def LF: char(. == "\n");
        def COMMA: char(. == ",");
        def DQUOTE: char(. == "\"");
        def DQUOTE2: DQUOTE | DQUOTE;
        def TEXTDATA: char(.=="\t" or .>=" " and .!="," and .!="\"" and .!="\u007F");
        def SPACE: optional(many(" \t"));
        def non_escaped: recurse(TEXTDATA);
        def escaped: DQUOTE | recurse(first(TEXTDATA , COMMA , CR , LF , DQUOTE2)) | DQUOTE;
        # Parse fields and records
        def field: . as $i | first((escaped|[true,$i,.]) , (non_escaped|[false,$i,.]));
        def record:
            def r:
                field as [$e,$i,$j]
                | if $e then $str[$i+1:$j-1] else $str[$i:$j] end
                , ($j | SPACE | COMMA | SPACE | r);
            0|r
        ;
        # Collect record fields
        [ record ]
    ;
    rtrimstr("\r\n") as $str | csv($str; $str|length)
;

def fromcsv(stream): # stream of records
    stream | fromcsv
;

# vim:ai:sw=4:ts=4:et:syntax=jq
