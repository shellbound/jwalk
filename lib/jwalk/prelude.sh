append() {
  eval "shift; $1=\"\$$1\$@\""
}

die() {
  warn "$(self): $@"
  try usage
  exit 1
}

escape() {
  puts "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"
}

try() {
  ! command -v "$1" >/dev/null || "$@"
}

warn() {
  puts "$@" >&2
}
