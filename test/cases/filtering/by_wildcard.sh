run jwalk -p "*" "corpus/package.json"
assert_status 0
assert_output "fixtures/parsing/standard/package"

run jwalk -lp "*" "corpus/package.json"
assert_status 0
assert_output "fixtures/parsing/leaf_only/package"

run jwalk -p "*url" "corpus/search.json"
assert_status 0
assert_output "fixtures/filtering/by_wildcard/search_urls"

run jwalk -p "*9*" "corpus/search.json"
assert_status 0
assert_output "fixtures/filtering/by_wildcard/nines"

run jwalk -p "*9*.score" "corpus/search.json"
assert_status 0
assert_output "fixtures/filtering/by_wildcard/nines_scores"
