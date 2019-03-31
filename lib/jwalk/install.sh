# jwalk: a streaming JSON parser for Unix
# (c) Sam Stephenson / https://jwalk.sh

set -e
[ -z "$JWALK_DEBUG" ] || set -x

PREFIX="${1%/}"

[ -n "$PREFIX" ] || {
  echo "usage: jwalk --install <prefix>"
  exit 1
} >&2

[ -d "$PREFIX" ] || {
  echo "jwalk: not a directory: $PREFIX"
  exit 1
} >&2

mkdir -p "$PREFIX/lib"
cp -Rv "$JWALK_LIB/jwalk/"* "$JWALK_LIB/jwalk.sh" "$PREFIX/lib"

mkdir -p "$PREFIX/bin"
ln -Fvs "../lib/jwalk.sh" "$PREFIX/bin/jwalk"
chmod +x "$PREFIX/bin/jwalk"
