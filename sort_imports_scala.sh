#!/bin/bash

print_imports_range() {
  awk '
    BEGIN {
      b = -1
      e = -1
    }
    /^import / {
      if ( b == -1 ) {
        b = NR
        e = NR
      } else if ( NR == e + 1 ) {
        e = NR
      } else {
        if ( b < e ) {
          print b ":" e
        }
        b = NR
        e = NR
      }
    }
    END {
      if ( b < e ) {
        print b ":" e
      }
    }
  ' $1
}

do_sort_imports_block() {
  f=$1
  while read range; do
    IFS=': ' read b e <<< $range
    c=$(($e - $b + 1))

    orignal_block=$(tail -n +$b $f | head -n $c)
    sorted_block=$(echo "$orignal_block" | LC_ALL=C sort)

    if [[ "$orignal_block" != "$sorted_block" ]]; then
      i=$b
      echo "$sorted_block" | while read line; do
        sed -i "$i c$line" $f
        i=$(($i + 1))
      done
    fi
  done
}

sort_imports() {
  f=$1
  echo "processing $f" 1>&2
  print_imports_range $f \
    | do_sort_imports_block $f
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
