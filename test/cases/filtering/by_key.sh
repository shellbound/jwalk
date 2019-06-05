run jwalk -p "sha" "corpus/tree.json"
assert_status 0
assert_output "fixtures/filtering/by_key/sha"

run jwalk -p "nonexistent" "corpus/search.json"
assert_status 0
assert_output "/dev/null"
