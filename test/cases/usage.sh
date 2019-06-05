run jwalk --help
assert_status 0
assert_output "fixtures/usage/help"

run jwalk --nonexistent
assert_status 1
assert_output "fixtures/usage/help"

run jwalk -e
assert_status 1
assert_output "fixtures/usage/missing_argument_e"

run jwalk -f
assert_status 1
assert_output "fixtures/usage/missing_argument_f"
