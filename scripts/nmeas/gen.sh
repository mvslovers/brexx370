#!/bin/bash
# gen.sh DIR KINDS : writes the measurement execs for KINDS (e.g. "i s") into DIR
d=$1; shift; t=scripts/nmeas/template.rexx
mk() { sed -e "s/@KIND@/$2/" -e "s/@N@/$3/" -e "s/@NP@/$4/" $t > "$d/$1.rexx"; }
for k in "$@"; do
  K=$(echo $k | tr a-z A-Z)
  case $k in
    i|s) sizes="10 100 1000 5000 10000 20000";;
    l|v) sizes="1000 10000";;
  esac
  for n in $sizes; do mk t$k$n $K $n 3; mk c$k$n $K $n 0; mk b$k$n $K $n -1; done
done
mk o10000i I 10000 1; mk o10000s S 10000 1
