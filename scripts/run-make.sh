#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(/usr/bin/dirname -- "$0")" && /bin/pwd -P)
ROOT_DIR=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && /bin/pwd -P)

if [ "$#" -ne 1 ]; then
  echo "usage: scripts/run-make.sh check|test" >&2
  exit 64
fi

case $1 in
  check|test)
    target=$1
    ;;
  *)
    echo "usage: scripts/run-make.sh check|test" >&2
    exit 64
    ;;
esac

exec /usr/bin/env \
  -u MAKEFILES \
  -u MAKEFLAGS \
  -u MFLAGS \
  -u MAKEOVERRIDES \
  -u GNUMAKEFLAGS \
  /usr/bin/make --no-print-directory -f "$ROOT_DIR/Makefile" "$target"
