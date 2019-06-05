run jwalk "corpus/geocode.json"
assert_status 0
assert_output "fixtures/parsing/standard/geocode"

run jwalk "corpus/package.json"
assert_status 0
assert_output "fixtures/parsing/standard/package"

run jwalk "corpus/search.json"
assert_status 0
assert_output "fixtures/parsing/standard/search"

run jwalk "corpus/tree.json"
assert_status 0
assert_output "fixtures/parsing/standard/tree"
