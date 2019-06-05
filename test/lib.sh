run() {
  RUN_COMMAND="$@"
  RUN_STATUS=0
  RUN_OUTPUT="$CHECK_TMP/run"
  PATH="$CHECK_ROOT/../bin:$PATH" "$@" >"$RUN_OUTPUT" 2>&1 || RUN_STATUS=$?
}

assert() {
  status=0
  message="$1"
  shift
  "$@" || {
    status=$?
    echo "assertion failed for command '$RUN_COMMAND': $message"
    cat "$RUN_OUTPUT"
  }
  return $status
}

assert_status() {
  assert "expected exit status to be $1 but was $RUN_STATUS" [ "$1" -eq "$RUN_STATUS" ]
}

assert_output() {
  assert "unexpected output" cmp -s "$RUN_OUTPUT" "$1" || {
    diff -au "$RUN_OUTPUT" "$1"
    exit 1
  }
}
