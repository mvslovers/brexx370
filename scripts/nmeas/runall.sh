#!/bin/bash
# runall.sh ENVFILE TAG : runs the batches against the target in ENVFILE
. "$1"; tag=$2
M=~/.mbt/versions/3.0.0-rc5/mbt
cd /home/mike/repos/mvs/brexx370-wt-qa-1559
rm -f test/{t,c,b,o}[isvl][0-9]*.rexx test/o[0-9]*[is].rexx
scripts/nmeas/gen.sh test i s l v
for b in "i:ci ti oi" "s:cs ts os" "l:cl tl" "v:cv tv"; do
  k=${b%%:*}; pre=${b#*:}; args=""
  for f in $(ls test | grep -E '\.rexx$' | sed 's/\.rexx//'); do
    case $f in
      [tcb][$k][0-9]*) args="$args --only $f";;
      o[0-9]*$k) args="$args --only $f";;
    esac
  done
  echo "BATCH $k: $args" >> /tmp/nm1559/runall-$tag.log
  $M run mvstest -- $args --timeout 3300 >> /tmp/nm1559/runall-$tag.log 2>&1
  cp build/mvstest.spool /tmp/nm1559/spool-$tag-$k.txt
done
echo FINISHED >> /tmp/nm1559/runall-$tag.log
