run jwalk -p "name" -p "description" -p "main" "corpus/package.json"
assert_status 0
assert_output "fixtures/filtering/by_multiple_patterns/package_properties"
