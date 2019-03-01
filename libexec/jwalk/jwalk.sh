#!/bin/sh
set -e

READLINK="$( which greadlink readlink | head -n 1 )"
[ -n "$READLINK" ] || {
  echo "jwalk: can't find readlink"
  exit 1
} >&2

abs_dirname() {
  path="$1"
  while :; do
    cd -P "${path%/*}"
    name="${path##*/}"
    if [ -L "$name" ]; then
      path="$("$READLINK" "$name")"
    else
      break
    fi
  done
  pwd
}

LIBEXEC="$(abs_dirname "$0")"

jwalk() {
  "$LIBEXEC"/jwalk-tokenize.sh | "$LIBEXEC"/jwalk-parse.awk
}

if [ -n "$1" ]; then
  jwalk <"$1"
else
  jwalk
fi
