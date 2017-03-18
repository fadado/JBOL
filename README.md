# ≈ JBOL ≈

**JBOL** is a collection of modules and tools for the **JQ** language.

## Modules

All **JBOL** modules reside in the `fadado.github.io` directory:

* **math**: miscelaneous mathematical functions.
* **prelude**: common services; to be included almost always.
* **schema**: JSON schema generation and validation.
* **set**:  objects managed as sets.
* **types**: type predicates.
* Generator related modules:
    + **generator/chance**: basic pseudo-random generators. To be replaced in future **JQ** releases.
    + **generator/choice**: combinatorial generators.
    + **generator/generator**: common operations on generators.
    + **generator/sequence**: mathematical sequences.
* String related modules:
    + **string/ascii**: functions in the `ctype.h` style for the ASCII encoding.
    + **string/latin1**: functions in the `ctype.h` style for the ISO-8859-1 encoding.
    + **string/regexp**: pattern matching using regular expressions.
    + **string/snobol**: pattern matching in the SNOBOL style.
    + **string/string**: common string operations, some in the Icon language style.

## Tools

Thin _Bash_ wrappers around **JQ** filters:

* **jgen**: generates JSON schemas for instance documents.
* **jval**: validates instance documents against a JSON schema.

## Installation

If you have the latests _GNU Make_ tool in your system run this command:

```
$ sudo make install
```

This will install modules and other data files to `/usr/local/share/jbol`, and
tools to `/usr/local/bin`.

### Manual installation

All provided modules are in the `fadado.github.io` directory. Copy this
directory to the top-level **JQ** modules path with commands equivalent to:

```sh
$ sudo mkdir -p /usr/local/share/jbol
$ sudo cp -r fadado.github.io /usr/local/share/jbol
```

The tools and related schema files can be installed with commands equivalent
to:

```sh
$ sudo mkdir -p /usr/local/bin
$ sudo cp bin/* /usr/local/bin
$ sudo cp -r schemata /usr/local/share/jbol
```

**Warning**: if you do not use `/usr/local/bin` for the script some harcoded
pathnames must be edited!

## Usage

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
$ jq -L/usr/local/share/jbol -f script.jq
```

To use the tools ask first for help:

```
$ jgen --help
jgen -- Generates JSON schemas for instance documents

Usage: jgen [-h | --help | -v | --version]
       jgen [options...] [files...]

jgen generates a JSON schema for each instance document read from the
standard input.  One or more files may be specified, in which case jgen will
read input from those instead.

Options:
    -a, --verbose-array     Add array constraints
    -c, --compact           Compact output
    -h, --help              Show this help
    -k, --sort-keys         Sort output keys 
    -n, --verbose-number    Add number constraints
    -o, --verbose-object    Add object constraints
    -r, --required          Add the 'required' keyword
    -s, --verbose-string    Add string constraints
    -v, --version           Print version information
```

```
$ jval --help
jval -- Validates an instance document against a JSON schema

Usage: jval [-h | --help | -v | --version]
       jval [options...] schema [file...]

jval validates against an schema a JSON instance document read from the
standard input.  One or more files may be specified, in which case jval will
read input from those instead.

Options:
    -h, --help              Show this help
    -q, --quiet             Suppress all normal output (status is zero or one)
    -s, --schema            Validates JSON schema against the meta schema
    -v, --version           Print version information
```

## Tests end examples

The `Makefile` has rules to help you run the tests included in the `tests`
directory. Run `make` to run all the tests or `make check` to run again all
tests.

Several **JQ** scripts are included in the `examples` directory.  The `Makefile` has
rules to help you run the examples, but you should study first the code to know
how each example works. As an example, this script generates in a smart way the
solutions for the classical _8 queens_ problem:

```
#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";

# Smart N-Queens

def queens($n):
    def safe($i; $j):
        every(
            range($i) as $k
            | .[$k] as $l
            | (($i-$k)|length) != (($j-$l)|length)
        )
    ;
    def qput($row; $avail):
        if $row == $n # $avail == []
        then .
        else
            $avail[] as $col # choose a column
            | keep(safe($row; $col);
                .[$row]=$col | qput($row+1; $avail-[$col]))
        end
    ;
    #
    [] as $board |
    0  as $first_row |
    [range($n)] as $available_columns |
    #
    $board|qput($first_row; $available_columns)
;

queens(8)

# vim:ai:sw=4:ts=4:et:syntax=jq
```

## Documentation

Please visit this repository [wiki](https://github.com/fadado/JBOL/wiki) for
more information.

<!--
vim:syntax=markdown:et:ts=4:sw=4:ai
-->
