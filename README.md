# JBOL

This project collects materials related to _jq_, mainly tests and examples
trying to help in the learning of the language.

## Usage

This project is managed using _GNU Make_. To know all available targets
execute `make help`.

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

## Documents

Some documents stored in this repository:

* The simplified _jq_ [grammar](docs/grammar.txt) extracted from the sources.
* The _jq_ [operators precedence](docs/operators.html) table.

## More about _jq_

To learn _jq_ study the following documents:

* The _jq_ [manual](http://stedolan.github.io/jq/).
* The definition of [builtins](https://github.com/stedolan/jq/blob/master/src/builtin.jq) not written in _C_.
* The official [tests](https://github.com/stedolan/jq/blob/master/tests/jq.test).
* The _jq_ [FAQ](https://github.com/stedolan/jq/wiki/FAQ).
* The _jq_ [cookbook](https://github.com/stedolan/jq/wiki/Cookbook).
* the _jq_ [wiki](https://github.com/stedolan/jq/wiki).
* The _jq_ [issues](https://github.com/stedolan/jq/issues) collected over the time.
* Simply [play](https://jqplay.org/) with _jq_!

## Author

Joan Josep Ordinas Rosa (<jordinas@gmail.com>)

<!--
vim:syntax=markdown:et:ts=4:sw=4:ai
-->
