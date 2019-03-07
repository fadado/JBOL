# _jq_ Distilled

This text tries to be the briefest possible description of the essential
characteristics of the jq language; it is therefore incomplete by definition.
It should also be noted that the author&rsquo;s mother tongue is not English, and
that any help received to improve the wording of the text will be well
received.


## `jq` and _jq_

The `jq` command-line processor transforms streams of input JSON values using one
or more combined filters written in the _jq_ language. The input may also consist
on UTF-8 text lines or a single big UTF-8 string. Filters are parameterized
generators that for each consumed JSON value produce a stream of zero or more
output JSON values.

### JSON values

JSON values are the only _jq_ values.

#### JSON grammar

```none
    Object                    Char
        {}                        any Unicode character except "
        { Members }                 or \ or control character
    Members                     \"
        Pair                    \\ \/
        Pair , Members          \b \f 
    Pair                        \n \r \t
        String : Value          \ufour-hex-digits
    Array                     Number
        []                        Int
        [ Elements ]              Int Frac
    Elements                      Int Exp
        Value                     Int Frac Exp
        Value , Elements      Int
    Value                         Digit
        String                    Digit1-9 Digits 
        Number                    - Digit
        Object                    - Digit1-9 Digits
        Array                 Frac
        true                      . Digits
        false                 Exp
        null                      Ex Digits
                              Digits
    String                        Digit
        ""                        Digit Digits
        " Chars "             Ex
    Chars                         e e+ e- E E+ E-
        Char
        Char Chars
```

#### _jq_ values

In the _jq_ language the constants `null`, `false` and `true`, number and string
literals and array and object constructors define JSON values; no other kind of
values exists. _jq_ adds the numeric constants `nan` and `infinite`, and also accepts
as an extension the literals `NaN` and `Inf` in JSON input (but not output) data.
_jq_ defines the following complete order for JSON values, including `nan` and
`infinite`:

```none
null < false < true < nan < -(infinite) < NUMBERS < infinite < STRINGS < ARRAYS < OBJECTS
```

Object constructors offer several syntactic extensions respect to JSON
literals, as the following equivalences show:

```none
    {foo: bar}         ≡  {"foo": bar}
    {foo}              ≡  {"foo": .foo}
    {$foo}             ≡  {"foo": $foo}
    {("fo"+"o"): bar}  ≡  {"foo": bar}
```

### Operators

_jq_ evaluation model is better understood adding to JSON values two non
assignable &ldquo;values&rdquo; denoted in this document by `@` (the _empty
stream_) and `!` (the _non-termination_ symbol).  New filters are built using
operators and special constructs.

#### Operators in increasing order of priority

| Operator | Associativity | Description |
| -------- | ------------- | ----------- |
| `(...)` | &nbsp; | scope delimiter and grouping operator |
| <code>&#124;</code> | right | compose/sequence two filters |
| `,` | left | concatenate/alternate two filters |
| `//` | right | coerces `null`, `false` and `@` to an alternative value |
| `=` <code>&#124;=</code> `+=` `-=` `*=` `/=` `%=` `//=` | nonassoc | assign; update |
| `or` | left | boolean &ldquo;or&rdquo; |
| `and` | left | boolean &ldquo;and&rdquo; |
| `==` `!=` `<` `>` `<=` `>=` | nonassoc | equivalence and precedence tests |
| `+` `-` | left | polymorphic plus and minus |
| `*` `/` `%` | left | polymorphic multiply and divide; modulo |
| `-` | none | prefix negation |
| `?` | none | postfix operator, coerces `!` to `@` |
| `?//` | nonassoc | destructuring alternative operator |


### Special constructs

The special constructs `if`, `reduce`, `foreach`, `label` and `try` extend _jq_
control flow capabilities. The postfix operator `?` is syntactic sugar for the
`try` special construct.

#### Schematic syntax for special constructs

```none
    def Name: Expression;
    def Name(Parameters): Expression;
    Term as Pattern { ?// Pattern }| Expression
    if Expression then Expr end
    if Expression then Expr else Expr end
    if Expression then Expr { elif Expr then Expr } else Expr end
    reduce Term as Pattern (Init; Update) # Init, Update and Extract are Expr.
    foreach Term as Pattern (Init; Update)
    foreach Term as Pattern (Init; Update; Extract)
    label $Name | {Expression |} break $Name
    try Expression
    try Expression catch Expression
```

The `as` construct binds variable names and supports array and object
destructuring. Binding of variables and sequencing and alternation of filters
can be described with the following equivalences:

```none
    (a₁,a₂,…,aₙ) as $a | f($a)  ≡  f(a₁),f(a₂),…,f(aₙ)
    (a₁,a₂,…,aₙ) | f            ≡  (a₁|f),(a₂|f),…,(aₙ|f)
    (a₁,a₂,…,aₙ) , (b₁,b₂,…,bₙ) ≡  a₁,a₂,…,aₙ,b₁,b₂,…,bₙ
```

### Filters

New filters can be defined with the `def` construct. Filters consume one input
value, can have extra parameters and produce zero or more output values.
Parameters are passed by name, or by value if prefixed with the character `$` in
the filter definition.

#### Core filters

| Filter | Description |
| ------ | ----------- |
| `.` | identity filter, produces unchanged its input value |
| `empty` | empty filter, does not produce any value on its output (_produces_ `@)` |
| `null` `false` | boolean &ldquo;false&rdquo; |
| `true` | boolean &ldquo;true&rdquo;, as everything else except `null` and `false` |
| `.k` `."k"` | object identifier-index; shorthand for `.["k"]` |
| `x[k]` | array index and generic object index |
| `x[i:j]` | array and string slice |
| `x[]` | array and object value iterator |
| `..` | recursively descends `.`, producing <code>.,.[]?,(.[]?&#124;.[]?),...</code> |
| `keys` | generates ordered array indices and object keys |
| `length` | size of strings, arrays and objects; absolute value of numbers |
| `del(path)` | removes `path` in the input value |
| `type` | produces as string the type name of JSON values |
| `explode`, `implode` | conversion of strings to/from code point arrays |
| `tojson`, `fromjson` | conversion of JSON values to/from strings |
| `"\(expr)"` | string interpolation |
| `@fmt` | format and escape strings |
| `error`, `error(value)` | signals an error aborting the current filter (_produces_ `!`); can be caught |
| `halt`, `halt_error(status)` | exits the program |

#### Algebraic laws

After parameter instantiation _jq_ filters are like mathematical relations on
JSON values, and follow several algebraic laws:

```none
    @ , A  ≡  A  ≡  A , @
    . | A  ≡  A  ≡  A | .
    @ | A  ≡  @  ≡  A | @

    A , (B , C)  ≡  (A , B) , C
    A | (B | C)  ≡  (A | B) | C
    (A , B) | C  ≡  (A | C) , (B | C)

    (A , B) | select(p)    ≡  (A | select(p)) , (B | select(p))
    select(p) | select(q)  ≡  select(q) | select(p)
    select(p) | select(p)  ≡  select(p)
    A | B | select(p)      ≡  A | select(B | p)

    ! | A  ≡  !  ≡  A | !
```


## Filters type

_jq_ has a dynamic type system but, to better understand filters behavior, is
advisable to add type signatures as comments. 

### Type signatures

Type signatures are a condensed syntax to specify filters input, output and
parameters type.

#### Proposed grammar for filter type signatures

```none
Type anotation                          Parameter              Value
    :: Places                               Value                  null
Places                                      Value->Stream¹         boolean
    Output                              Output                     number
    => Output                               Stream                 string
    Input => Output                         !²                     array
    (Parameters) => Output              Stream                     object
    Input|(Parameters) => Output            @³                     [Value]
Parameters                                  Value                  {Value}
    Parameter                               ?Value⁴                <Value>⁶
    Parameter; Parameters                   *Value                 Value^Value⁷
Input                                       +Value                 Letter⁸
    Value                                   Stream!⁵               Name⁹
```

Notes:

1. Parameters passed by name are like parameterless filters.
2. The character `!` is the display symbol for non-terminating filters type.
3. The character `@` denotes the empty stream.  Use only when results are never expected.
4. Occurrence indicators (`?`, `*`, `+`) have the usual meaning.
5. Streams output type always have an implicit union with `!`.  To add only
   when non-termination is expected.
6. Indistinct array or object: `<a> ≡ [a]^{a}`.
7. Union of two value types.
8. Single lowercase letters are type variables representing indeterminate JSON
   value types.
9. Named object (construct only with the underscore character and uppercase
   letters).

### Type signature examples

Those are the type signatures for some _jq_ builtins:

```none
    # empty      :: a => @
    # .          :: a => a
    # error      :: a => !
    # first(g)   :: a|(a->*b) => ?b
    # isempty(g) :: a|(a->*b) => boolean
    # select(p)  :: a|(a->boolean) => ?a
    # recurse(f) :: a|(a->?a) => +a
    # while(p;f) :: a|(a->boolean;a->?a) => *a
    # until(p;f) :: a|(a->boolean;a->?a) => a!
    # map(f)     :: [a]|(a->*b) => [b]
```


## Path expressions

Path expressions play an important role in _jq_, and are dificult
to explain briefly.

### Grammar for path expressions

Very simplified grammar, not the actual grammar!

```none
    PathExpr:
        ('empty' | '.' | Route | Cond | Call) ('|' PathExpr)*
    Cond:
        a JQ conditional evaluating to a path expression
    Call:
        a JQ function call evaluating to a path expression
    Route:
        Step Step*
    Step:
        '.' (name | string | Bracket) Bracket*
    Bracket:
        Iterator | Slice | ASubscript | OSubscript
    Iterator:
        '[' ']'
    Slice:
        '[' index ':' index | index ':' | ':' index ']'
    ASubscript:
        '[' index (',' index)* ']'
    OSubscript:
        '[' string (',' string)* ']'
    name:
        a JQ identifier: [A-Za-z_][A-Za-z_0-9]*
    string:
        expression producing a JQ/JSON string
    index:
        expression producing a JQ array index (JSON integer)
```

### Array representation format

Paths are represented by arrays of array indices, object keys
and slice objects with the form `{"start":number,"end":number}`.

