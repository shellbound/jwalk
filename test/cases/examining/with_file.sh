run jwalk -f "cases/examining/coordinates.awk" "corpus/geocode.json"
assert_status 0
assert_output "fixtures/examining/with_file/coordinates"
