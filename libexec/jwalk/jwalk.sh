#!/bin/sh
set -e

abs_dirname() {
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

LIBEXEC="$(abs_dirname "$0")"

jwalk() {
  "$LIBEXEC"/jwalk-tokenize.sh | "$LIBEXEC"/jwalk-parse.awk
}

if [ -n "$1" ]; then
  jwalk <"$1"
else
  jwalk
fi
