#!/bin/sh
# jwalk: a streaming JSON parser for Unix
# https://jwalk.sh
#
# Copyright (c) 2019 Sam Stephenson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

set -e
[ -z "$JWALK_DEBUG" ] || set -x

warn() {
  printf "%s\n" "$1" >&2
}

usage() {
  warn "usage: jwalk [-l] [-e script ...] [-f script-file ...] [json-file]"
  warn "(see https://jwalk.sh for more information and examples)"
  [ -z "$1" ] || exit "$1"
}


# Find ourselves

realpath_dirname() {
  path="$1"
  while :; do
    cd -P "${path%/*}"
    name="${path##*/}"
    if [ -L "$name" ]; then
      link="$(ls -l "$name")"
      path="${link##* $name -> }"
    else
      break
    fi
  done
  pwd
}

export JWALK_LIB="$(realpath_dirname "$0")"
TMPDIR="${TMPDIR:-/tmp}"


# Process command-line arguments

unset args examining json_file stored_scripts

store() {
  path="${TMPDIR%/}/jwalk.$$.$1"
  escaped_path="$(escape "$path")"
  append stored_scripts "$escaped_path "
  printf '%s\n' "$2" > "$path"
  trap 'eval "rm -f $stored_scripts"' EXIT
}

append() {
  eval "shift; $1=\"\$$1\$@ \""
}

escape() {
  printf '%s\n' "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"
}

index=1

while [ $index -le $# ]; do
  eval 'this="$'$index'"'
  eval 'next="$'$(( index + 1 ))'"'
  incr=1

  while
    retry=0
    case "$this" in
      -e)
        [ -n "$next" ] || usage 1
        store $index "$next"
        append args -f "$escaped_path"
        examining=1
        incr=2
        ;;
      -f)
        [ -n "$next" ] || usage 1
        append args -f '"$'$(( index + 1 ))'"'
        examining=1
        incr=2
        ;;
      -h|--help)
        usage 0
        ;;
      --install)
        exec sh "$JWALK_LIB/jwalk/install.sh" "$next"
        ;;
      -l|--leaf-only|-le|-lf)
        append args -v leafonly=1
        if [ "${#this}" -eq 3 ]; then
          this="-${this#-l}"
          retry=1
        fi
        ;;
      -*)
        usage 1
        ;;
      *)
        [ -z "$json_file" ] || usage 1
        json_file="$this"
        ;;
    esac
    [ $retry -ne 0 ]
  do :; done

  index=$(( index + incr ))
done

eval "set -- $args"


# Run jwalk

walk() {
  tokenize | parse
}

examine() {
  awk -v "examining=$examining" -f "$JWALK_LIB/jwalk/examine.awk" "$@"
}

parse() {
  awk -f "$JWALK_LIB/jwalk/parse.awk"
}

tokenize() {
  sh "$JWALK_LIB/jwalk/tokenize.sh"
}

if [ -n "$json_file" ] && [ "$json_file" != "-" ]; then
  exec < "$json_file"
fi

walk | examine "$@"
