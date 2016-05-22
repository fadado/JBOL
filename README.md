# _jq_ learn

In my effort to learn _jq_ I developed a series of tests, examples, tools&hellip;
I hope this material will be useful for you.

## Usage

This project is managed using _GNU Make_. In my system, writing `make` in the
project directory followed by an space and a **TAB** shows all subcommands
(_make targets_) available.

See the [Makefile](./Makefile) for more usage hints.

## Tests

The directory [tests](./tests) has files with tests to study. Each file has several tests, and
each test is a group of three lines: program, input, expected output.  Blank
lines and lines starting with `#` are ignored.

To run all tests simply execute `make`, or `make check` to force the execution,
again, of previously successful tests.

## Examples

Several [examples](./examples) are available. For example, `make cross` produce the
intersections of two words, like:

    computer       c          c         c          c
    e              e    computer        e          e
    n              n          n         n          n
    t         computer        t         t          t
    e              e          e   computer         e
    r              r          r         r   computer

See the [Makefile](./Makefile) to know how to execute the examples.

## Tools

The [bin](./bin) directory has scripts to convert between JSON and YAML and `yq`, a
wrapper to `jq` allowing to query YAML files directly:

    $ yq '.store.book[2]' data/store.yaml
    author: Herman Melville
    category: fiction
    isbn: 0-553-21311-3
    price: 8.99
    title: Moby Dick

## More about _jq_

To learn _jq_ I recommend the study of the following documents:

* The _jq_ [manual](http://stedolan.github.io/jq/).
* The definition of [builtins](https://github.com/stedolan/jq/blob/master/src/builtin.jq) not written in _C_.
* The official [tests](https://github.com/stedolan/jq/blob/master/tests/jq.test).
* The simplified _jq_ [grammar](docs/grammar.txt) I extracted from the sources.
* The _jq_ [FAQ](https://github.com/stedolan/jq/wiki/FAQ).
* The _jq_ [cookbook](https://github.com/stedolan/jq/wiki/Cookbook).
* More pages in the _jq_ [wiki](https://github.com/stedolan/jq/wiki).
* The _jq_ [issues](https://github.com/stedolan/jq/issues) collected over the time.
* Simply [play](https://jqplay.org/) with _jq_!

## Author

Joan Josep Ordinas Rosa (<jordinas@gmail.com>)

<!--
vim:syntax=markdown:et:ts=4:sw=4:ai
-->
