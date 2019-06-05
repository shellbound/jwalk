run jwalk -e '{print path; print key; print type; print value; print "---"}' "corpus/geocode.json"
assert_status 0
assert_output "fixtures/examining/variables/standard"

run jwalk -e '{print keys[3], keys[2], keys[1], keys[-1], keys[-2], keys[-3]}' "corpus/geocode.json"
assert_status 0
assert_output "fixtures/examining/variables/indexed_keys"
