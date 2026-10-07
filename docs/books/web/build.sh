#!/bin/sh
# Builds the web form of the BREXX/370 manuals into OUT: the three books as
# sites (guide/, reference/, library/), their PDFs and a landing page.  Read
# the Docs runs it with OUT=$READTHEDOCS_OUTPUT/html; locally any directory.
#   sh docs/books/web/build.sh /tmp/site
# Needs typst on the PATH (the version CI pins) and the bookmaster submodule.
set -eu
out=${1:?usage: build.sh OUTDIR}
mkdir -p "$out"
out=$(cd "$out" && pwd)
cd "$(dirname "$0")/.."
web="--features html,bundle --format bundle --input bm-bundle=1 --root . --font-path bookmaster/fonts"
pdf="--root . --font-path bookmaster/fonts --ignore-system-fonts"
typst compile $web ml03-0001.typ "$out/guide"
typst compile $web ml03-0002.typ "$out/reference"
typst compile $web ml03-0003.typ "$out/library"
for n in ml03-0001 ml03-0002 ml03-0003; do typst compile $pdf $n.typ "$out/$n-0.pdf"; done
cp web/index.html "$out/index.html"
cp -R "$out/guide/fonts" "$out/fonts"
cp "$out/guide/bookmaster.css" "$out/bookmaster.css"
