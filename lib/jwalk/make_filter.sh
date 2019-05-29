# jwalk: a streaming JSON parser for Unix
# (c) Sam Stephenson / https://jwalk.sh

set -e
[ -z "$JWALK_DEBUG" ] || set -x

# pattern   filter                          meaning
# ^a        ^a(\t|$)                        path starts with the key "a"
# *.*       (^|\t)[^\t]*?\t[^\t]*?(\t|$)    path has at least two keys
# a         (^|\t)a(\t|$)                   path has the key "a"
#           (^|\t)(\t|$)                    path has the key ""
# a.b.c.    (^|\t)a\tb\tc\t(\t|$)           path has the keys "a", "b", and "c", followed by the key ""
# a*c       (^|\t)a[^\t]*?c(\t|$)           path has a key matching the glob "a*c"
# a.*.c     (^|\t)a\t[^\t]*?\tc(\t|$)       path has the key "a", followed by one key, followed by the key "c"
# a.**.c    (^|\t)a\t(.*?\t)*c(\t|$)        path has the key "a", followed by zero or more keys, followed by the key "c"
# c$        (^|\t)c$                        path ends with the key "c"

before='(^|\t)'
regexp=''
after='(\t|$)'
index=0
end=$((${#1} - 1))
rest="$1     "

while
  head="${rest%"${rest#??????}"}"
  rest="${rest#?}"
  [ -n "$head" ]
do
  case "$head" in
    '**.'* )
      value='(.*?\t)*'
      rest="${rest#??}"
      ;;
    '*'* )
      value='[^\t]*?'
      ;;
    '.'* )
      value='\t'
      ;;
    '\u'* )
      value='\'"$head"
      rest="${rest#?????}"
      ;;
    '\'* )
      value="${head%????}"
      rest="${rest#?}"
      ;;
    '^'* | '$'* )
      value="${head%?????}"
      if [ "$value" = '^' ] && [ $index -eq 0 ]; then
        before="$value"
        value=""
      elif [ "$value" = '$' ] && [ $index -eq $end ]; then
        after="$value"
        value=""
      else
        value='\'"$value"
      fi
      ;;
    '('* | ')'* | '['* | ']'* | '{'* | '}'* | '|'* | '?'* )
      value='\'"${head%?????}"
      ;;
    * )
      value="${head%?????}"
      ;;
  esac
  regexp="${regexp}${value}"
  index=$((index + 1))
done

printf '%s%s%s\n' "$before" "$regexp" "$after"
