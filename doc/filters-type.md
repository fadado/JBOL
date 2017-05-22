# Type of filters

JQ has a dynamic type system but, to better understand filters behavior, type
annotations can be added inside comments.

## Grammar for JQ filters type anotations

The following table use only ASCII characters.  If desired, the Unicode
characters ∅ (U+2205) and ⊥ (U+22A5) can be used as typographical alternatives
for the characters `@` and `!`.

```none
Type anotation				Parameter		Value
    :: Places                               Value                   null
Places                                      Value->Stream(1)        boolean
    Output                              Output                      number
    => Output                               Stream                  string
    Input| => Output                        !(2)                    array
    (Parameters) => Output              Stream                      object
    Input|(Parameters) => Output            @(3)                    [Value]
Parameters                                  Value)                  {Value}
    Parameter                               ?Value(4)               <Value>(6)
    Parameter; Parameters                   *Value                  Letter(7)
Input                                       +Value                  Value^Value(8)
    Value                                   stream^!(5)             TYPE_NAME(9)
```

Notes:

1. Parameters passed by name are like parameterless filters.
1. The symbol `!` denote the value produced for filters that cancel.
2. The symbol `@` denote the empty stream.
4. Occurrence indicators (`?`, `*`, `+`) have the usual meaning.
5. Streams type always have an implicit union with `!`. To be added explicitly only when cancellation is expected.
6. Indistinct array or object: <a> = [a]^{a}.
7. Union of two value types.
8. Single lowercase letters represent indeterminate JSON value types.
9. Named object (use only underscore character and uppercase letters).

