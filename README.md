# jwalk

jwalk is a **streaming JSON parser for Unix:** _streaming_, in that individual [JSON][json] tokens are parsed as soon as they are read from the input stream, and _for Unix_, in that its tab-delimited output is designed to be used and manipulated by the standard Unix toolset. jwalk…

* parses large documents slowly, but steadily, in memory space proportional to the key depth of the document
* runs from source on any contemporary POSIX system
* is written in standard [awk][awk], [sed][sed], and [sh][sh], and does not require a C compiler or precompiled binaries
* can easily be embedded in another project

jwalk is useful for working with data from JSON APIs in shell scripts, especially in bootstrap environments, but can be applied to a variety of other situations. It is a powerful command-line tool in its own right, with built-in pattern matching and support for awk scripts called _examiners_.

## How It Works

The `jwalk` command reads a JSON document from standard input or from a file specified as an argument.

A pipeline inside jwalk transforms the document stream into a series of _tokens_, and then parses the tokens into _records_, one record per line, on standard output.

Each record is a sequence of tab-separated fields:

* zero or more fields, collectively the _path_, containing the string keys used to access the value, followed by
* one field specifying the value's _type_, followed by
* one field representing the _value_ itself.

The type is one of `number`, `string`, `boolean`, `null`, `array`, or `object`. String values are encoded as UTF-8, and are unescaped with the exception of `\n`, `\t`, and `\\`.

### Examples

(In this documentation, ` ▷ ` represents a tab character.)

Basic JSON values produce one record each:

    $ echo '123.45' | jwalk
    number ▷ 123.45

    $ echo '"acab"' | jwalk
    string ▷ acab

    $ echo 'true' | jwalk
    boolean ▷ true

    $ echo 'null' | jwalk
    null ▷

Arrays and objects produce one record representing the type, followed by zero or more records representing their key-value pairs:

    $ echo '[80,"http"]' | jwalk
    array ▷
    0 ▷ number ▷ 80
    1 ▷ string ▷ http

    $ echo '{"version":"1.0.0"}' | jwalk
    object ▷
    version ▷ string ▷ 1.0.0

You can use the `-l` (or `--leaf-only`) command-line option to omit the type record:

    $ echo '[80,"http"]' | jwalk -l
    0 ▷ number ▷ 80
    1 ▷ string ▷ http

    $ echo '{"version":"1.0.0"}' | jwalk -l
    version ▷ string ▷ 1.0.0

An array of objects looks like:

    $ echo '[{"lat":45.1,"lng":13.6,"name":"Rovinj"},
    >        {"lat":44.9,"lng":13.8,"name":"Pula"}]' | jwalk
    array ▷
    0 ▷ object ▷
    0 ▷ lat ▷ number ▷ 45.1
    0 ▷ lng ▷ number ▷ 13.6
    0 ▷ name ▷ string ▷ Rovinj
    1 ▷ object ▷
    1 ▷ lat ▷ number ▷ 44.9
    1 ▷ lng ▷ number ▷ 13.8
    1 ▷ name ▷ string ▷ Pula

With `-l`, the same array looks like:

    $ echo '[{"lat":45.1,"lng":13.6,"name":"Rovinj"},
    >        {"lat":44.9,"lng":13.8,"name":"Pula"}]' | jwalk -l
    0 ▷ lat ▷ number ▷ 45.1
    0 ▷ lng ▷ number ▷ 13.6
    0 ▷ name ▷ string ▷ Rovinj
    1 ▷ lat ▷ number ▷ 44.9
    1 ▷ lng ▷ number ▷ 13.8
    1 ▷ name ▷ string ▷ Pula

## Filtering Records By Path

You can use the `-p <pattern>` (or `--pattern <pattern>`) command-line option to instruct jwalk to print only the records whose keys match the given _pattern_.

A pattern describes a key or sequence of keys present anywhere in a record's path. For example, the pattern `a` matches only the records whose path contains a key `"a"`.

Patterns may contain any of the following special characters:

Character | Matches
--------- | -------
`^`       | the beginning of the path
`$`       | the end of the path
`.`       | the boundary between two adjacent keys
`*`       | zero or more occurrences of any character in a key
`.**`     | zero or more keys

### Example Patterns

Pattern  | Matches records
-------- | ---------------
`^a`     | starting with the key `"a"`
`*.*`    | with at least two keys
`a`      | with the key `"a"`
(empty)  | With the key `""`
`a.b.c.` | with the keys `"a"`, `"b"`, and `"c"`, followed by the key `""`
`a*c`    | having any key which starts with `a` and ends with `c`
`a.*.c`  | with the key `"a"`, followed by one key, followed by the key `"c"`
`a.**.c` | with the key `"a"`, followed by zero or more keys, followed by the key `"c"`
`c$`     | ending with the key `"c"`

## Examining Records With awk

jwalk's tab-delimited, line-separated output is designed to be consumed by standard Unix tools such as `awk`, `cut`, `grep`, and `sed`.

In particular, awk's default field and record separators handle jwalk's output, such that each record's fields are accessible as `$1`, `$2`, and so on:

    $ echo '["awk","cut","grep","sed"]' \
    >      | jwalk -l | awk '{print $3}'
    awk
    cut
    grep
    sed

A jwalk _examiner_ is an [awk script][awk] with a runtime environment tailored for parsing jwalk output. Specifically, examiners have access to special variables with details about the record.

Pass one or more `-e <script>` options to jwalk on the command line to specify examiners inline:

    $ echo '["awk","cut","grep","sed"]' \
    >      | jwalk -l -e '{print value}'
    awk
    cut
    grep
    sed

You can also store examiners in files and load them with the `-f <scriptfile>` command-line option.

### Special Variables

In addition to the full set of [special variables][awk-special-variables] available to all awk programs, examiners have access to the following additional variables:

Variable name  | Description
-------------- | -----------
`keys`         | an array of zero or more strings, representing the key path, indexed forward starting at 1 and backward at -1
`path`         |  the key path as a string, with each key separated by a tab (or `FS`)
`key`          | the rightmost or last key of the key path; equivalent to `keys[-1]`
`type`         | the type of the JSON value
`leaf`         | false when the type is `array` or `object`; true otherwise
`value` or `_` | the string representation of the JSON value

### Unescaping String Values

The characters `\n`, `\t`, and `\` remain escaped in special variables. Pass these variables through the `unescape()` function to replace the escaped characters with unescaped values.

## Configuring jwalk

By default, jwalk uses the `awk` and `sed` commands found in your `PATH`. You can tell it to use specific commands by setting the `JWALK_AWK` or `JWALK_SED` environment variables, such as with `JWALK_AWK=gawk` or `JWALK_SED=/usr/local/bin/gsed`.

You can log the shell commands issued by jwalk to standard error by setting the `JWALK_DEBUG` environment variable to `1`.

## Installing and Embedding jwalk

To install jwalk, run `bin/jwalk --install` with the path to the directory where jwalk should be installed. The directory must already exist. For example:

    $ sudo bin/jwalk --install /usr/local

Once you have a `jwalk` command installed in your path, you can run `jwalk --install` to embed jwalk into another project:

    $ mkdir -p vendor/jwalk
    $ jwalk --install vendor/jwalk
    $ vendor/jwalk/bin/jwalk -l ...

To install a git checkout of jwalk for development, either place a symlink to `bin/jwalk` somewhere in your `PATH`, or place jwalk's `bin` directory in your `PATH`.

## Testing jwalk

Run `test/check` to start the jwalk test harness. This script runs each test case in `test/cases/` and logs the results in TAP format to standard output. If any test case fails, the harness exits with a non-zero status.

Input data lives in `test/corpus/` and expected output lives in `test/fixtures/`. When writing new test cases, use the existing test cases and file hierarchy as a guide.

## Contributing Back

jwalk is open-source software, freely distributable under the terms of an [MIT-style license][license]. The [source code][source] is hosted on GitHub.

We welcome contributions in the form of bug reports, pull requests, or thoughtful discussions in the GitHub [issue tracker][issues].

Please note that this project is released with a [Contributor Code of Conduct][conduct]. By participating in this project you agree to abide by its terms.

---

[© Sam Stephenson][license] • Part of the [Shellbound Project][shellbound]

[awk]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html
[awk-special-variables]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html#tag_20_06_13_03
[conduct]: CODE_OF_CONDUCT
[issues]: https://github.com/shellbound/jwalk/issues
[json]: http://www.json.org
[license]: LICENSE
[sed]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/sed.html
[source]: https://github.com/shellbound/jwalk
[sh]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
[shellbound]: https://github.com/shellbound
