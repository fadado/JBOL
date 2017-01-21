# ≋ JBOL ≋

JBOL is a collection of modules for the **jq** language.

## Installation and usage

All the provided modules are under the `fadado.github.io` directory. Copy this
directory to your toplevel **jq** modules path with a command equivalent to

```sh
$ cp -r fadado.github.io TOP-PATH
```

In your **jq** scripts include or import modules with directives like

```jq
include "fadado.github.io/prelude";
import "fadado.github.io/string" as str;
```

And finally run your script with the appropriated `-L` option:

```sh
$ jq -LTOP-PATH -f script.jq
```

## Documentation

Please visit this repository [wiki](https://github.com/fadado/JBOL/wiki) for more information.

<!--
vim:syntax=markdown:et:ts=4:sw=4:ai
-->
