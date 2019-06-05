keys[-2] == "location" && (key == "lat" || key == "lng") {
  coords[key] = value
}

END {
  print coords["lat"] ", " coords["lng"]
}
