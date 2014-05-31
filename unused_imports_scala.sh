#!/bin/bash

check_import() {
  local import="$1"
  local c=$(echo $import | sed "s/^.*\.\([a-zA-Z]\+\)\s*$/\\1/")
  local f="$2"
  grep -v "^\s*import [a-zA-Z.]\+\s*$" "$f" | grep "\b$c\b" &> /dev/null || {
    echo " - $import"
  }
}

unused_imports() {
  local f="$1"
  echo "$f"
  imports=$(grep "^\s*import [a-zA-Z.]\+\s*$" "$f" | grep -v "scala.language.")
  for import in ${imports[@]}; do
    check_import "$import" "$f"
  done
}

main() {
  local dir=$(readlink -f ${1:-$PWD})
  IFS='
'
  for f in $(find $dir -name "*.scala"); do
    unused_imports "$f"
  done
}

main "$@"
