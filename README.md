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

To install jwalk, run `sh lib/jwalk.sh --install` with the path to the directory where jwalk should be installed. For example:

    $ sh lib/jwalk.sh --install /usr/local

Once you have a `jwalk` command in your path, you can run `jwalk --install` to embed jwalk into another project:

    $ mkdir -p vendor/jwalk
    $ jwalk --install vendor/jwalk
    $ vendor/jwalk/bin/jwalk -l ...

If the installation destination is a directory named `lib`, jwalk will install just the library files without creating an executable symlink:

    $ jwalk --install ~/myproject/lib
    $ sh ~/myproject/lib/jwalk.sh -l ...

---

© 2019 Sam Stephenson
