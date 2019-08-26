examine() {
  awk -f "$JWALK_LIB/commands/examine.awk" -v "examining=$examining" -v "filter=$filter" "$@"
}

install() {
  . "$JWALK_LIB/commands/install.sh" "$@"
}

make_filter() {
  . "$JWALK_LIB/commands/make_filter.sh" "$@"
}

parse() {
  awk -f "$JWALK_LIB/commands/parse.awk"
}

tokenize() {
  . "$JWALK_LIB/commands/tokenize.sh"
}

###

awk() {
  command "${JWALK_AWK:-awk}" "$@"
}

sed() {
  command "${JWALK_SED:-sed}" "$@"
}
