#!/bin/sh
# Writes a Brotli copy, name.br, next to each file of a Flutter web build that
# compression shrinks, for the server to send to browsers that take Brotli.
# Brotli at its best is too slow to run per request, and makes main.dart.js
# and canvaskit.wasm a fifth smaller again than gzip. The server falls back to
# gzip for files without a copy, or with one older than the file.
#
# Usage: precompress.sh <build dir>     (needs the brotli command)
set -eu

dir=${1:?usage: precompress.sh <build dir>}
command -v brotli >/dev/null || { echo "precompress.sh: brotli is not installed" >&2; exit 1; }

# The types compress.go compresses, 1 KB or more, except source maps and
# debug symbols, which browsers do not load. Names without a dot are
# assets/NOTICES.
find "$dir" -type f -size +1023c \
  \( -name '*.js' -o -name '*.mjs' -o -name '*.wasm' -o -name '*.json' \
  -o -name '*.html' -o -name '*.css' -o -name '*.svg' -o -name '*.txt' \
  -o -name '*.ttf' -o -name '*.otf' -o -name '*.frag' -o -name '*.bin' \
  -o ! -name '*.*' \) -print0 |
  xargs -0 -r -n 1 -P "$(nproc 2>/dev/null || echo 2)" sh -c '
    brotli -q 11 -f -k -- "$1"
    # A copy no smaller than the file is no use to anyone.
    [ "$(wc -c <"$1.br")" -lt "$(wc -c <"$1")" ] || rm -f -- "$1.br"
  ' sh
