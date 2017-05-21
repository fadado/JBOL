# Type of filters

JQ has a dynamic type system but, to better understand filters behavior, type
annotations can be added inside comments.

## Grammar for JQ filters type anotations

The following table use only ASCII characters.  If desired, the Unicode
characters ∅ (U+2205) and ⊥ (U+22A5) can be used as typographical alternatives
for the characters `@` and `!`.

```none
Type anotation                      Input                Stream
    :: Places                           Type                 @(4)
Places                              Parameter                ?Value(5)
    Output                              Type                 *Value
    => Output                       Output                   +Value
    Input| => Output                    Type             Value
    (Parameters) => Output              Type^!(1)            null
    Input|(Parameters) => Output    Type                     boolean
Parameters                              Name                 number
    Parameter                           Stream               string
    Parameter; Parameters               Value                array
                                        !(2)                 object
                                    Name(3)                  [Value]
                                        Value->Value         {Value}
                                        Value->Stream        <Value>(6)
                                                             a..z(7)
                                                             Value^Value(8)
                                                             TYPE_NAME(9)
```

Notes:

1. Output types have always an implicit union with `!`. To be added explicitly
   only when cancellation is expected.
2. The character `!` denote the value produced for filters that cancel.
3. Parameters passed by name are like parameterless filters.
4. The character `@` denote the empty stream.
5. Occurrence indicators (`?`, `*`, `+`) have the regular expressions usual meaning.
6. Indistinct array or object.
7. Single lowercase letter represent indeterminate JSON value types.
8. Union of two value types.
9. Named object (use uppercase letters and underscore character only).

## Types allowed in each place

The grammar alone does not enforce some existing restrictions on the places
where each type can appear.

|        | input | parameter | output |
|--------|:-----:|:---------:|:-------:
| value  | *     | *         | *      |
| stream |       |           | *      |
| name   |       | *         |        | 
| !      |       |           | *      |

