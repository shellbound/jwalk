run jwalk -p "^sha" "corpus/tree.json"
assert_status 0
assert_output "fixtures/filtering/by_anchor/begins_with_sha"

run jwalk -p "*.sha$" "corpus/tree.json"
assert_status 0
assert_output "fixtures/filtering/by_anchor/ends_with_any_key_and_sha"

run jwalk -p "^items.15.name$" "corpus/search.json"
assert_status 0
assert_output "fixtures/filtering/by_anchor/matching_exact_path"
