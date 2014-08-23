#!/bin/bash

BASE_DIR=$(readlink -f "$(dirname "$0")")

sh $BASE_DIR/sort_imports_scala.sh "$@"
sh $BASE_DIR/unused_imports_scala.sh "$@"
