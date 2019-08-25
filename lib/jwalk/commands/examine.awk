BEGIN {
  FS = OFS = "\t"
}

{
  type = $(NF - 1)
  leaf = type != "array" && type != "object"

  if (leafonly && !leaf) {
    next
  }

  if (length(filter) > 0 && !path_matches(filter)) {
    next
  }

  if (examining) {
    examine()
  } else {
    print
  }
}

function examine() {
  load_path_keys()
  key = $(NF - 2)
  value = _ = $(NF)
}

function path_matches(filter) {
  load_path_keys()
  return match(path, filter)
}

function load_path_keys(i, k, v) {
  if (path_keys_source != $0) {
    path_keys_source = $0
    depth = NF - 2

    split("", keys)
    split("", path_offsets)
    path = ""

    for (i = 1; i <= depth; i++) {
      k = sprintf("%d", i)
      keys[k] = keys[sprintf("%d", -(depth - i + 1))] = v = $(i)
      path_offsets[k] = length(path)
      path = (path_offsets[k] ? path FS : path) v
    }
  }
}

function unescape(str) {
  if (str == 0 && length(str) == 0) {
    str = value
  }

  gsub(/\\n/, "\n", str)
  gsub(/\\t/, "\t", str)
  gsub(/\\\\/, "\\", str)

  return str
}
