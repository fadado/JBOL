**jq** simplified grammar extracted from the files `parser.y` and `lexer.l` in the **jq** sources.

Only for language lawyers ;-)

```yacc
TopLevel:
        Module Imports Exp  |
        Module Imports FuncDefs 

Module:
        %empty  |
        "module" Exp ';' 

Imports:
        %empty  |
        Import Imports 

Import:
        ImportWhat ';'  |
        ImportWhat Exp ';' 

ImportWhat:
        "import"  ImportFrom "as" '$' IDENT  |
        "import"  ImportFrom "as" IDENT      |
        "include" ImportFrom 

ImportFrom:
          String 

FuncDefs:
        %empty  |
        FuncDef FuncDefs 

FuncDef:
        "def" IDENT ':' Exp ';'  |
        "def" IDENT '(' Params ')' ':' Exp ';' 

Params:
        Param  |
        Params ';' Param 

Param:
        '$' IDENT  |
        IDENT 

Exp:
        FuncDef Exp  |
        Term "as" Pattern '|' Exp  |
        "reduce"  Term "as" Pattern '(' Exp ';' Exp ')'          |
        "foreach" Term "as" Pattern '(' Exp ';' Exp ';' Exp ')'  |
        "foreach" Term "as" Pattern '(' Exp ';' Exp ')'          |
        "if" Exp "then" Exp ElseBody  |
        "try" Exp "catch" Exp  |
        "try" Exp  |
        "label" '$' IDENT '|' Exp  |
        Exp '?'        |
        Exp '=' Exp    |
        Exp "or" Exp   |
        Exp "and" Exp  |
        Exp "//" Exp   |
        Exp "//=" Exp  |
        Exp "|=" Exp   |
        Exp '|' Exp    |
        Exp ',' Exp    |
        Exp '+' Exp    |
        Exp "+=" Exp   |
        '-' Exp        |
        Exp '-' Exp    |
        Exp "-=" Exp   |
        Exp '*' Exp    |
        Exp "*=" Exp   |
        Exp '/' Exp    |
        Exp '%' Exp    |
        Exp "/=" Exp   |
        Exp "%=" Exp   |
        Exp "==" Exp   |
        Exp "!=" Exp   |
        Exp '<' Exp    |
        Exp '>' Exp    |
        Exp "<=" Exp   |
        Exp ">=" Exp   |
        Term 

Pattern:
       '$' IDENT           |
        '[' ArrayPats ']'  |
        '{' ObjPats '}' 

ArrayPats:
        Pattern  |
        ArrayPats ',' Pattern 

ObjPats:
        ObjPat  |
        ObjPats ',' ObjPat 

ObjPat:
        '$' IDENT                |
        IDENT       ':' Pattern  |
        Keyword     ':' Pattern  |
        String      ':' Pattern  |
        '(' Exp ')' ':' Pattern

ElseBody:
        "elif" Exp "then" Exp ElseBody  |
        "else" Exp "end" 

Term:
        '.'   |
        ".."  |
        "break" '$' IDENT    |
        Term FIELD '?'       |
        FIELD '?'            |
        Term '.' String '?'  |
        '.' String '?'       |
        Term FIELD           |
        FIELD                |
        Term '.' String      |
        '.' String           |
        Term '[' Exp ']' '?'          |
        Term '[' Exp ']'              |
        Term '[' ']' '?'              |
        Term '[' ']'                  |
        Term '[' Exp ':' Exp ']' '?'  |
        Term '[' Exp ':' ']' '?'      |
        Term '[' ':' Exp ']' '?'      |
        Term '[' Exp ':' Exp ']'      |
        Term '[' Exp ':' ']'          |
        Term '[' ':' Exp ']'          |
        LITERAL  |
        String   |
        FORMAT   |
        '(' Exp ')'     |
        '[' Exp ']'     |
        '[' ']'         |
        '{' MkDict '}'  |
        '$' "__loc__"   |
        '$' IDENT       |
        IDENT           |
        IDENT '(' Args ')'

Args:
        Arg  |
        Args ';' Arg 

Arg:
        Exp 

MkDict:
        %empty      |
        MkDictPair  |
        MkDictPair ',' MkDict 

MkDictPair:
        IDENT   ':' ExpD        |
        Keyword ':' ExpD        |
        String  ':' ExpD        |
        String                  |
        '$' IDENT               |
        IDENT                   |
        '(' Exp ')' ':' ExpD 

ExpD:
        ExpD '|' ExpD  |
        '-' ExpD       |
        Term 

Keyword:
        "module"   |
        "import"   |
        "include"  |
        "def"      |
        "as"       |
        "if"       |
        "then"     |
        "else"     |
        "elif"     |
        "end"      |
        "and"      |
        "or"       |
        "reduce"   |
        "foreach"  |
        "try"      |
        "catch"    |
        "label"    |
        "break"    |
        "__loc__" 

String:
        "\""  QQString "\""  |
        FORMAT "\""  QQString "\"" 

/*
 * IDENT:       ([a-zA-Z_][a-zA-Z_0-9]*::)*[a-zA-Z_][a-zA-Z_0-9]*
 * FIELD:       \.[a-zA-Z_][a-zA-Z_0-9]* 
 * LITERAL:     a JSON number
 * FORMAT:      "@"[a-zA-Z0-9_]+
 * QQString:    a JSON string content with interpolations \(...)
 */

```
