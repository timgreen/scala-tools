#!/bin/bash

print_imports_line_number() {
  awk '/^import / {print NR}' $1
}

turn_into_block_range() {
  local b=-1
  local e=-1
  while read ln; do
    if (( $b == -1 )); then
      b=$ln
      e=$ln
    elif (( $ln == $e + 1 )); then
      e=$ln
    else
      if (( $b < $e )); then
        echo $b:$e
      fi
      b=$ln
      e=$ln
    fi
  done
  if (( $b != -1 )) && (( $b < $e )); then
    echo $b:$e
  fi
}

sort_import_block() {
  f=$1
  while read range; do
    IFS=: read b e <<< $range
    c=$(($e - $b + 1))

    i=$b
    tail -n +$b $f | head -n $c | LC_ALL=C sort | while read line; do
      sed -i "$i c$line" $f
      i=$(($i + 1))
    done
  done
}

sort_imports() {
  f=$1
  echo "processing $f" 1>&2
  print_imports_line_number $f \
    | turn_into_block_range \
    | sort_import_block $f
}

main() {
  local dir=$(readlink -f ${1:-$PWD})
  IFS='
'
  for f in $(find $dir -name "*.scala"); do
    sort_imports $f
  done
}

main "$@"
