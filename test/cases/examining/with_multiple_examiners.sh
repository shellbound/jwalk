run jwalk -f "cases/examining/address.awk" -f "cases/examining/coordinates.awk" "corpus/geocode.json"
assert_status 0
assert_output "fixtures/examining/with_multiple_examiners/address_and_coordinates"

run jwalk -f "cases/examining/address.awk" -e 'BEGIN {print "Basecamp, LLC"}' "corpus/geocode.json"
assert_status 0
assert_output "fixtures/examining/with_multiple_examiners/name_and_address"
