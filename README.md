# jwalk

jwalk is a streaming JSON parser for Unix:

* _streaming_, in that individual JSON tokens are parsed as soon as they are read from input;
* _for Unix_, in that its line-based output is designed to be used and manipulated by the standard Unix toolset.

jwalk is written in standard [awk][awk], [sed][sed], and [sh][sh], and does not require a C compiler. It is intended to run from source on any contemporary POSIX system.

It can parse large documents slowly, but steadily, in memory space proportional to the key depth of the document.

## Reading Records From JSON

The `jwalk` command is a filter which transforms a stream of JSON _tokens_ from standard input into a stream of tab-delimited, line-separated _records_ on standard output.

A token is an indivisible, non-whitespace span of JSON, such as a number, string, boolean, bracket, or brace.

Every line of jwalk output is a record, arranged as follows, with each field separated by a tab character:

* zero or more fields, collectively the _path_, containing the string keys used to access the value, followed by
* one field specifying the value's _type_, followed by
* one field representing the _value_ itself.

The type is one of `number`, `string`, `boolean`, `null`, `array`, or `object`. String values are encoded as UTF-8, and are unescaped with the exception of `\n`, `\t`, and `\\`.

### Examples

    $ echo 123.45 | jwalk
    number ▷ 123.45

    $ echo true | jwalk
    boolean ▷ true

    $ echo '"acab"' | jwalk
    string ▷ acab

    $ echo null | jwalk
    null ▷

    $ echo '[123,"acab"]' | jwalk
    array ▷
    0 ▷ number ▷ 123
    1 ▷ string ▷ acab

    $ echo '{"version":"1.0.0"}' | jwalk
    object ▷
    version ▷ string ▷ 1.0.0

In general, records of type `array` and `object` provide structural information. Use the `-l` (or `--leaf-only`) flag to skip these records.

    $ echo '[123,"acab"]' | jwalk -l
    0 ▷ number ▷ 123
    1 ▷ string ▷ acab

    $ echo '{"version":"1.0.0"}' | jwalk -l
    version ▷ string ▷ 1.0.0

## Processing Records As Text

For simple array documents, pipe jwalk's output to `cut -f 3` to see the array's values:

    $ echo '[1,2,3]' | jwalk -l | cut -f 3
    1
    2
    3

Or `wc -l` to count the number of elements in the array:

    $ echo '[1,2,3]' | jwalk -l | wc -l
    3

For simple object documents, pipe jwalk's output to `cut -f 1` to see the object's keys:

    $ echo '{"first":"Sam","last":"Stephenson"}' | jwalk -l | cut -f 1
    first
    last

Or `cut -f 1,3` to see the key-value pairs:

    $ echo '{"first":"Sam","last":"Stephenson"}' | jwalk -l | cut -f 1,3
    first ▷ Sam
    last ▷ Stephenson

The `jwalk` command also accepts a filename from the command line.

Use `grep` to filter records of interest by path:

    $ curl -sLO https://unpkg.com/turbolinks@beta/package.json
    $ jwalk -l package.json | grep -E 'scripts\t' | cut -f 2
    clean
    build
    watch
    start
    test

## Examining Records With awk

When a situation calls for more control over record output than `grep` and `cut` can provide, consider writing a jwalk _examiner_. An examiner is an [awk script][awk] pre-configured with variables for accessing record data.

Variable name | Description
------------- | -----------
`keys`        | an array of zero or more strings, representing the key path, indexed forward starting at 1 and backward at -1
`path`        |  the key path as a string, with each key separated by a tab (or `FS`)
`key`         | the rightmost or last key of the key path; equivalent to `keys[-1]`
`type`        | the type of the JSON value
`leaf`        | false when the type is `array` or `object`; true otherwise
`value`       | (aliased as `_`) the string representation of the JSON value

Pass one or more `-e <script>` options on the command line to specify examiners inline:

    $ jwalk -l -e '$1 == "scripts" {print key}' package.json
    clean
    build
    watch
    start
    test

Store more complex examiners in files and load them with the `-f <scriptfile>` command-line option.

## Installing and Embedding jwalk

To install jwalk, run `sh lib/jwalk.sh --install` with the path to the directory where jwalk should be installed. For example:

    $ sh lib/jwalk.sh --install /usr/local

Once you have a `jwalk` command in your path, you can run `jwalk --install` to embed jwalk into another project:

    $ mkdir -p vendor/jwalk
    $ jwalk --install vendor/jwalk
    $ vendor/jwalk/bin/jwalk -l ...

---

[© Sam Stephenson](LICENSE)

[awk]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html
[sed]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/sed.html
[sh]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
