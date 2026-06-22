#!/bin/sh
set -eu

case $0 in
  /*) script_path=$0 ;;
  *) script_path=$(/bin/pwd -P)/$0 ;;
esac

link_count=0
while [ -L "$script_path" ]; do
  link_count=$((link_count + 1))
  if [ "$link_count" -gt 40 ]; then
    echo "repository verification entrypoint has too many symbolic links" >&2
    exit 66
  fi

  if ! link_target_with_sentinel=$(/usr/bin/readlink -n "$script_path" && printf x); then
    echo "repository verification entrypoint could not read symbolic link" >&2
    exit 66
  fi
  link_target=${link_target_with_sentinel%x}
  case $link_target in
    /*) script_path=$link_target ;;
    *) script_path=$(/usr/bin/dirname "$script_path")/$link_target ;;
  esac
done

if [ ! -f "$script_path" ]; then
  echo "repository verification entrypoint did not resolve to a regular file" >&2
  exit 66
fi

SCRIPT_DIR=$(CDPATH='' cd -P "$(/usr/bin/dirname "$script_path")" && /bin/pwd -P)
ROOT_DIR=$(CDPATH='' cd -P "$SCRIPT_DIR/.." && /bin/pwd -P)

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
