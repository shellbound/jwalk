# jwalk

jwalk is a streaming JSON parser for Unix:

* _streaming_, in that individual JSON tokens are parsed as soon as they are read
* _for Unix_, in that its line-based output is designed to be used and manipulated by the standard Unix toolset

jwalk is written in POSIX-compliant awk, sed, and sh, and does not require a C compiler. It is intended to run from source on any contemporary Unix system.

It can parse large documents slowly, but steadily, in constant memory space.

Each line of jwalk output consists of tab-separated fields describing a JSON token:

* zero or more fields, collectively the _path_, containing the string keys used to access the token, followed by
* one field specifying the token’s _type_, followed by
* one field containing the token’s string _value_

String values are encoded as UTF-8, and are unescaped with the exception of `\n`, `\t`, and `\\`.

When you need more control over the output than `grep` and `cut` provide, you can write a jwalk _examiner_. An examiner is an Awk script with [easy access to parser fields](lib/jwalk/examine.awk).

To install jwalk, create an executable symlink  to `lib/jwalk.sh` named `jwalk` and place it in your path.

You can easily embed jwalk in another project. Just include jwalk’s `lib/` directory and run `sh lib/jwalk.sh`.

---

© 2019 Sam Stephenson
