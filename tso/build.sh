#!/usr/bin/env bash
# tso/build.sh - build the ZMG0001 decks (not an mbt target).
#   tso/build.sh exec    decks for LMOD EXEC: IKJCT430.o, IKJCT437.o,
#                        and the unpatched IKJCT430.orig.o
#   tso/build.sh rxdrv   RXDRV + IKJCT437 -> build/tso/RXDRV.xmit
# The EXEC load module is NOT linked here: the usermod ships object
# decks, and SMP link-edits them into the INSTALLED module, which keeps
# the service already on it (KB MVS-SMP-0004). IKJCT430.orig.o lets
# tso/lmod_link.py prove that the IBM source reproduces the installed
# module before the patched one is linked the same way.
# The IBM sources assemble with the pinned as370 and the macro libraries
# of the mvs38src project (MVS38SRC, default ../mvs38src). as370 can
# write an object and exit 0 at severity 8, so the listing is checked
# for diagnostics too, not only the exit status.
# Taken over from mvslovers/rexx370 tso/build.sh (ZMG0002), main f574e90.

set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/.." && pwd)"
MVS38SRC="${MVS38SRC:-$repo/../mvs38src}"
out="$repo/build/tso"
mkdir -p "$out"

as370_bin="$MVS38SRC/work/src-states/bin/as370-main"
macros=(
  tk5-recon pls-header
  mvsce-2.1.4-dlib/AMACLIB mvsce-2.1.4-dlib/AMODGEN
  mvsce-2.1.4-dlib/AGENLIB mvsce-2.1.4-dlib/ATSOMAC
  mvsce-2.1.4-dlib/ATCAMMAC mvsce-2.1.4-dlib/APVTMACS
  tape mirror erep-set amaclib-live
)
incs=()
for m in "${macros[@]}"; do
  incs+=(-I "$MVS38SRC/work/macros/$m")
done

asm() { # asm <source> <object>
  local src="$1"
  local obj="$2"
  local log="$obj.log"
  if ! ASMDATE=10/05/26 ASMTIME=12.00 "$as370_bin" "${incs[@]}" \
       -o "$obj" "$src" >"$log" 2>&1; then
    cat "$log"; echo "as370 failed: $src" >&2; exit 1
  fi
  if grep -E -q ' ERROR:|WARNING:|Statements? Flagged' "$log"; then
    cat "$log"; echo "as370 diagnostics: $src" >&2; exit 1
  fi
}

case "${1:-}" in
  exec)
    asm "$MVS38SRC/src/IKJCT430.ASM" "$out/IKJCT430.orig.o"
    asm "$here/IKJCT430.ASM" "$out/IKJCT430.o"
    asm "$here/IKJCT437.ASM" "$out/IKJCT437.o"
    echo "built $out/IKJCT430.orig.o $out/IKJCT430.o $out/IKJCT437.o"
    ;;
  rxdrv)
    asm "$here/IKJCT437.ASM" "$out/IKJCT437.o"
    asm "$here/RXDRV.ASM" "$out/RXDRV.o"
    # --norent --noreus: RXDRV keeps its save area in the CSECT.
    ld370 -o "$out/RXDRV.lm" --name RXDRV --entry RXDRV --blocksize 19069 \
          --norent --noreus "$out/RXDRV.o" "$out/IKJCT437.o" -iebcopy
    ld370 --pack RXDRV="$out/RXDRV.lm.iebcopy" -o "$out/RXDRV" \
          --blocksize 19069 --norent --noreus -xmit
    echo "built $out/RXDRV.xmit"
    ;;
  *)
    echo "usage: tso/build.sh exec|rxdrv" >&2
    exit 2
    ;;
esac
