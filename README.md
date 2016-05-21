# JQ learn

In my effort to learn [JQ](http://stedolan.github.io/jq/) I developed a series of tests, examples, tools&hellip;
I hope this material will be useful for you.

# Usage

This project is managed using _GNU Make_. In my system, writing `make` in the
project directory followed by an space and a **TAB** show all subcommands (make targets) available.

See the `Makefile` for more usage hints.

## Tests

The directory `tests` has files with tests to study. Each file has several tests, and
each tests is a group of three lines: program, input, expected output.  Blank
lines and lines starting with # are ignored.

To run all tests simply execute `make` or `make check` to force the execution,
again, of previously successful tests.

## Examples

Several examples are available. For example, `make cross` produce all the
intersections of two words, like:

    computer       c          c         c          c
    e              e    computer        e          e
    n              n          n         n          n
    t         computer        t         t          t
    e              e          e   computer         e
    r              r          r         r   computer

See the `Makefile` to know how to execute the examples.

## Tools

The `bin` directory has scripts to convert between JSON and YAML and `yq`, a
wrapper to `jq` allowing to query YAML files directly:

    $ yq '.store.book[2]' data/store.yaml
    author: Herman Melville
    category: fiction
    isbn: 0-553-21311-3
    price: 8.99
    title: Moby Dick

# Author

Joan Ordinas (<jordinas@gmail.com>)

<!--
vim:syntax=markdown:et:ts=4:sw=4:ai
-->
