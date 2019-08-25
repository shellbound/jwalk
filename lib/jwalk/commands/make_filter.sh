set -e
[ -z "$JWALK_DEBUG" ] || set -x

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
