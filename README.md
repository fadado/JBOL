# ≈ JBOL ≈

**JBOL** is a collection of modules for the **JQ** language.

## Installation and usage

All modules provided are in the `fadado.github.io` directory. Copy this
directory to your top-level **JQ** modules path with a command equivalent to

```sh
$ cp -r fadado.github.io TOP-PATH
```

In your **JQ** scripts include or import modules with directives like

```jq
import "fadado.github.io/regexp" as re;
import "fadado.github.io/string" as str;
```

and then use the modules services in your code:

```jq
def remove_digits($s):
    $s | str::translate("01234567890"; "")
;
def normalize_space($s):
    $s | [re::split] | str::join(" ")
;
```

Finally, run your script with the `jq` appropriated `-L` option:

```sh
$ jq -LTOP-PATH -f script.jq
```

## Documentation

Please visit this repository [wiki](https://github.com/fadado/JBOL/wiki) for more information.

<!--
vim:syntax=markdown:et:ts=4:sw=4:ai
-->
