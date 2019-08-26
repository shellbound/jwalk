parse_option_arguments_for() {
  callback="$1"
  iterator="parse_$1_option_argument"
  option_arguments=""
  shift

  this_index=1
  last_index=$#
  while [ $this_index -le $last_index ]; do
    next_index=$((this_index+1))
    eval 'this_value="$'$this_index'"'
    eval 'next_value="$'$next_index'"'

    retry=1
    while [ $retry != 0 ]; do
      retry=0
      option="$this_value"
      case "$option" in
      --?* )
        ;;
      -??* )
        retry="${this_value#??}"
        option="${option%"$retry"}"
        this_value="-${this_value#??}"
      esac
      "$iterator" "$option" $this_index || try usage 1
    done
    this_index=$next_index
  done

  eval "set -- $option_arguments"
  "$callback" "$@"
}

append_option_arguments() {
  for arg; do
    append option_arguments " $(escape "$arg")"
  done
}

read_option_value() {
  if [ $this_index -lt $last_index ]; then
    next_index=$((next_index+1))
    eval "$1"'="$next_value"'
  else
    die "missing argument for option '$this_value'"
  fi
}

invalid_option() {
  die "invalid option '$this_value'"
}
