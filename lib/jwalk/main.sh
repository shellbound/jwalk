require "commands"
require "options"

main() {
  unset filter json_file
  parse_option_arguments_for walk "$@"
}

usage() {
  warn "usage: $(self) [-l] [-e script ...] [-f script-file ...] [-p pattern ...] [file]"
  warn "(see https://jwalk.sh for more information and examples)"
}

walk() {
  filter="${filter#?}"
  open "$json_file"
  tokenize | parse | examine "$@"
}

parse_walk_option_argument() {
  unset pattern script script_file variable
  this="$1"
  index=$2

  case "$this" in
    -e )
      examining=1
      read_option_value script
      store_script "$index.awk" "$script"
      append_option_arguments -f "$script_file"
      ;;
    -f )
      examining=1
      read_option_value script_file
      append_option_arguments -f "$script_file"
      ;;
    -h | --help )
      usage 2>&1
      exit
      ;;
    -l | --leaf-only )
      append_option_arguments -v leafonly=1
      ;;
    -p | --pattern )
      read_option_value pattern
      append filter "|$(make_filter "$pattern")"
      ;;
    -v )
      read_option_value variable
      append_option_arguments -v "$variable"
      ;;
    --version )
      version
      exit
      ;;
    -?* )
      invalid_option
      ;;
    * )
      [ -z "$json_file" ] || die "too many input files"
      json_file="$this"
  esac
}

open() {
  if [ "$1" != "-" ] && [ -n "$1" ]; then
    exec < "$1"
  fi
}

store_script() {
  script_dir="${TMPDIR%/}/jwalk.$$"
  script_file="$script_dir/$1"
  mkdir -p "$script_dir"
  puts "$2" > "$script_file"
  trap 'rm -fr "${TMPDIR%/}/jwalk.$$"' EXIT
}

version() {
  puts "$(self) 0.9.0"
}
