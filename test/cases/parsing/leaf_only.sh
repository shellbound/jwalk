run jwalk -l "corpus/geocode.json"
assert_status 0
assert_output "fixtures/parsing/leaf_only/geocode"

run jwalk -l "corpus/package.json"
assert_status 0
assert_output "fixtures/parsing/leaf_only/package"

run jwalk -l "corpus/search.json"
assert_status 0
assert_output "fixtures/parsing/leaf_only/search"

run jwalk -l "corpus/tree.json"
assert_status 0
assert_output "fixtures/parsing/leaf_only/tree"
