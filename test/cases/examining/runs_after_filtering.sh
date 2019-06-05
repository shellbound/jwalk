run jwalk -p "items.*.url" -e "{print _}" "corpus/search.json"
assert_status 0
assert_output "fixtures/examining/runs_after_filtering/search_urls"

run jwalk -le "{print path}" "corpus/package.json"
assert_status 0
assert_output "fixtures/examining/runs_after_filtering/package_leaf_paths"
