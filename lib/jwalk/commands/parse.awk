# The parser is modeled as a state machine with the following states:
#
#     0       expecting any value
#     1       expecting object property key
#     2       expecting next object property in sequence, or end of object
#     3       expecting object property separator
#     4       expecting object property value
#     5       expecting array entry
#     6       expecting next array entry in sequence, or end of array

BEGIN {
  FS = ""
  OFS = "\t"
  state = 0
  stack(keys)
  stack(states)
}

/^{/ {
  if (state == 0 || state == 4 || state == 5) {
    push(states, state)
    state = 1
    visit("object")
  } else {
    unexpected()
  }
}

/^}/ {
  if (state == 1 || state == 2) {
    state = pop(states)
    advance()
  } else {
    unexpected()
  }
}

/^\[/ {
  if (state == 0 || state == 4 || state == 5) {
    push(states, state)
    state = 5
    visit("array")
    push(keys, dtoa(0))
  } else {
    unexpected()
  }
}

/^]/ {
  if (state == 5 || state == 6) {
    state = pop(states)
    pop(keys)
    advance()
  } else {
    unexpected()
  }
}

/^:/ {
  if (state == 3) {
    state = 4
  } else {
    unexpected()
  }
}

/^,/ {
  if (state == 2) {
    state = 1
  } else if (state == 6) {
    state = 5
    push(keys, dtoa(pop(keys) + 1))
  } else {
    unexpected()
  }
}

/^"/ { #"
  if (state == 1) {
    state = 3
    push(keys, unquote())
  } else if (state == 0 || state == 4 || state == 5) {
    visit("string")
    advance()
  } else {
    unexpected()
  }
}

/^[0-9-]/ {
  if (state == 0 || state == 4 || state == 5) {
    visit("number")
    advance()
  } else {
    unexpected()
  }
}

/^null|^true|^false/ {
  if (state == 0 || state == 4 || state == 5) {
    visit($0 == "null" ? $0 : "boolean")
    advance()
  } else {
    unexpected()
  }
}

function advance() {
  if (state == 4) {
    state = 2
    pop(keys)
  } else if (state == 5) {
    state = 6
  }
}

function visit(type,  path, value) {
  path = join(keys)
  if (type == "string") {
    value = unquote()
  } else if (type == "number" || type == "boolean") {
    value = $0
  } else {
    value = ""
  }
  print(unescape((length(path) ? path OFS : "") type OFS value))
}

function unexpected() {
  error("unexpected '" $0 "'")
}

function unquote() {
  return substr($0, 2, length($0) - 2)
}

function unescape(value) {
  if (match(value, /\\[\/"bfr]/)) { #"
    gsub(/\\"/, "\"", value)
    gsub(/\\\//, "/", value)
    gsub(/\\b/, "\b", value)
    gsub(/\\r/, "\r", value)
    gsub(/\\f/, "\f", value)
  }

  if (match(value, /\\u[[:xdigit:]]{4}/)) {
    value = unescape_ucs2(value)
  }

  return value
}

function unescape_ucs2(value,  i, len, ucs2_hex, ucs2_codepoints) {
  while (match(value, /(\\u[[:xdigit:]]{4})+/)) {
    len = split(substr(value, RSTART + 2, RLENGTH - 2), ucs2_hex, /\\u/)
    stack(ucs2_codepoints)

    for (i = 1; i <= len; i++) {
      push(ucs2_codepoints, sprintf("%d", "0x" ucs2_hex[dtoa(i)]))
    }

    value = substr(value, 1, RSTART - 1) \
      ucs2_codepoints_to_utf8(ucs2_codepoints) \
      substr(value, RSTART + RLENGTH)
  }
  return value
}

function ucs2_codepoints_to_utf8(ucs2_codepoints,  value, next_value, key, next_key, head) {
  head = ucs2_codepoints["head"]
  result = key = ""

  while (key != head) {
    next_key = key "#"
    value = ucs2_codepoints[key]
    next_value = ucs2_codepoints[next_key]

    if (value >= 55296 && value <= 56319 && int(next_value / 1024) == 55) {
      value = ((value % 1024) * 1024) + (next_value % 1024) + 65536
      key = next_key "#"
    } else {
      key = next_key
    }

    result = result unicode_codepoint_to_utf8(value)
  }

  return result
}

function unicode_codepoint_to_utf8(codepoint) {
  if (codepoint < 127) {
    return sprintf("%c",
      codepoint)
  } else if (codepoint < 2047) {
    return sprintf("%c%c",
      192 + ((int(codepoint / 64) % 32) % 64),
      128 + ((codepoint % 64) % 128))
  } else if (codepoint < 65535) {
    return sprintf("%c%c%c",
      224 + ((int(codepoint / 4096) % 16) % 32),
      128 + ((int(codepoint / 64) % 64) % 128),
      128 + ((codepoint % 64) % 128))
  } else if (codepoint < 1114111) {
    return sprintf("%c%c%c%c",
      240 + ((int(codepoint / 262144) % 8) % 16),
      128 + ((int(codepoint / 4096) % 64) % 128),
      128 + ((int(codepoint / 64) % 64) % 128),
      128 + ((codepoint % 64) % 128))
  } else {
    return sprintf("%c%c%c",
      239, 191, 189)
  }
}

function dtoa(value) {
  return sprintf("%d", value)
}

function stack(array) {
  array["head"] = ""
}

function push(array, value,  head) {
  head = array["head"]
  array[head] = value
  array["head"] = head "#"
}

function pop(array,  head, value) {
  head = array["head"]
  if (head == "") {
    error("stack underflow")
  } else {
    array["head"] = head = substr(head, 2)
    value = array[head]
    delete array[head]
    return value
  }
}

function join(array,  head, result, key, next_key) {
  head = array["head"]
  result = key = ""

  while (key != head) {
    next_key = key "#"
    result = result array[key] (next_key == head ? "" : OFS)
    key = next_key
  }

  return result
}

function error(message) {
  warn("error: " message)
  exit(1)
}

function warn(message) {
  print(message) >"/dev/stderr"
}
