# jwalk: a streaming JSON parser for Unix
# (c) Sam Stephenson / https://jwalk.sh

set -e
[ -z "$JWALK_DEBUG" ] || set -x

tokenize() {
  sh "$JWALK_LIB/jwalk/tokenize.sh"
}

parse() {
  awk -f "$JWALK_LIB/jwalk/parse.awk"
}

examine() {
  awk -v "examining=$examining" -f "$JWALK_LIB/jwalk/examine.awk" "$@"
}

install() {
  sh "$JWALK_LIB/jwalk/install.sh" "$@"
}

usage() {
  warn "usage: jwalk [-l] [-e script ...] [-f script-file ...] [json-file]"
  warn "(see https://jwalk.sh for more information and examples)"
  [ -z "$1" ] || exit "$1"
}

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

warn() {
  printf "%s\n" "$1" >&2
}


# Process command-line arguments

unset args examining json_file stored_scripts
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
        install "$next"
        ;;
      -l|--leaf-only|-le|-lf)
        append args -v leafonly=1
        if [ "${#this}" -eq 3 ]; then
          this="-${this#-l}"
          retry=1
        fi
        ;;
      -?*)
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


# Walk

if [ "$json_file" != "-" ] && [ -n "$json_file" ]; then
  exec < "$json_file"
fi

tokenize | parse | examine "$@"
