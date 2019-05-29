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
  awk -f "$JWALK_LIB/jwalk/examine.awk" "$@" -v "examining=$examining" -v "filter=$filter"
}

make_filter() {
  sh "$JWALK_LIB/jwalk/make_filter.sh" "$@"
}

install() {
  sh "$JWALK_LIB/jwalk/install.sh" "$@"
}

usage() {
  warn "usage: jwalk [-l] [-e script ...] [-f script-file ...] [-p pattern ...] [file]"
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

awk() {
  command "${JWALK_AWK:-awk}" "$@"
}

sed() {
  command "${JWALK_SED:-sed}" "$@"
}

sh() {
  command "${JWALK_SH:-sh}" "$@"
}


# Process command-line arguments

unset args examining filter json_file stored_scripts
index=1

while [ $index -le $# ]; do
  eval 'this="$'$index'"'
  eval 'next="$'$(( index + 1 ))'"'
  incr=1

  while
    retry=0
    case "$this" in
      -e)
        store $index "$next"
        append args -f "$escaped_path"
        examining=1
        incr=2
        ;;
      -f)
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
      -l|--leaf-only|-le|-lf|-lp)
        append args -v leafonly=1
        if [ "${#this}" -eq 3 ]; then
          this="-${this#-l}"
          retry=1
        fi
        ;;
      -p|--pattern)
        filter="${filter}|$(make_filter "$next")"
        incr=2
        ;;
      -v)
        append args -v "$next"
        incr=2
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

  if [ $incr -gt 1 ] && [ $index -eq $# ]; then
    warn "jwalk: missing argument for option $this"
    usage 1
  else
    index=$(( index + incr ))
  fi
done

eval "set -- $args"
filter="${filter#?}"


# Walk

if [ "$json_file" != "-" ] && [ -n "$json_file" ]; then
  exec < "$json_file"
fi

tokenize | parse | examine "$@"
