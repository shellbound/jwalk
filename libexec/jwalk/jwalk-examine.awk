BEGIN {
  FS = OFS = "\t"
}

{
  examine()
}

function examine(i, v) {
  depth = NF - 2
  split("", keys)
  path = ""
  for (i = 1; i <= depth; i++) {
    keys[sprintf("%d", i)] = keys[sprintf("%d", -(depth - i + 1))] = v = $(i)
    path = (length(path) ? path FS : path) v
  }

  key = $(NF - 2)
  type = $(NF - 1)
  value = _ = $(NF)
  leaf = type != "array" && type != "object"
}

function unescape(str) {
  str = str == 0 && length(str) == 0 ? value : str
  gsub(/\\n/, "\n", str)
  gsub(/\\t/, "\t", str)
  gsub(/\\\\/, "\\", str)
  return str
}
