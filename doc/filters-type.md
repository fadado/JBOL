# Type of filters

JQ has a dynamic type system but, to better understand filters behavior, type
signatures can be added inside comments.

## Grammar for JQ filters type signatures

The notation uses only ASCII characters.

```none
Type anotation				Parameter		Value
    :: Places                               Value                  null
Places                                      Value->Stream'1        boolean
    Output                              Output                     number
    => Output                               Stream                 string
    Input| => Output                        !'2                    array
    (Parameters) => Output              Stream                     object
    Input|(Parameters) => Output            @'3                    [Value]
Parameters                                  Value                  {Value}
    Parameter                               ?Value'4               <Value>'6
    Parameter; Parameters                   *Value                 Value^Value'7 
Input                                       +Value                 Letter'8
    Value                                   stream!'5              Name'9
```

Notes:

1. Parameters passed by name are like parameterless filters.
2. The character `!` is the display symbol for non-terminating filters type.
3. The character `@` denotes the empty stream.  Use only when results are never expected.
4. Occurrence indicators (`?`, `*`, `+`) have the usual meaning.
5. Streams output type always have an implicit union with `!`.  To add only when abortion is expected.
6. Indistinct array or object: `<a> = [a]^{a}`.
7. Union of two value types.
8. Single lowercase letters are type variables representing indeterminate JSON value types.
9. Named object (construct only with the underscore character and uppercase letters).

