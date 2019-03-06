#!/bin/sh

CHARS="$(printf '\n\t')"
LF="${CHARS%?}"
TAB="${CHARS#?}"

sed -e '
  s/\\"/'"$TAB"'/g
  s/"[^"]*"/\'"$LF"'&\'"$LF"'/g
' |

sed -e '
  /".*"$/ !{
    s/[][,:}{}]/\'"$LF"'&\'"$LF"'/g
  }
  s/'"$TAB"'/\\"/g
' |

sed -e '
  s/^[ '"$TAB"']*//
  /^$/d
'
