keys[-3] == "address_components" && key == "long_name" {
  address_value = value
}

keys[-2] == "types" {
  if (!length(address[value])) {
    address[value] = address_value
  }
}

END {
  printf("%s %s %s\n%s %s %s\n%s\n",
    address["street_number"],
    address["route"],
    address["subpremise"],
    address["locality"],
    address["administrative_area_level_1"],
    address["postal_code"],
    address["country"])
}
