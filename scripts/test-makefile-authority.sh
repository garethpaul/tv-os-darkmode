#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
MAKEFILE=$ROOT_DIR/Makefile
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/tvos-make-authority-XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM

CONTROL_DIR=$TEMP_ROOT/control
ATTACKER_ROOT=$TEMP_ROOT/attacker
MARKER=$TEMP_ROOT/make-syntax-expanded
PYTHON_LOG=$TEMP_ROOT/python.log
mkdir -p "$CONTROL_DIR" "$ATTACKER_ROOT"

run_make() {
  (cd "$CONTROL_DIR" && /usr/bin/make --no-print-directory -f "$MAKEFILE" "$@")
}

fake_python=$TEMP_ROOT/python-safe
cat >"$fake_python" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"$PYTHON_LOG"
exit 0
EOF
chmod +x "$fake_python"

: >"$PYTHON_LOG"
run_make lint ROOT="$ATTACKER_ROOT" PYTHON="$fake_python" >/dev/null
grep -F "$ROOT_DIR/scripts/check_tvos_contracts.py" "$PYTHON_LOG" >/dev/null
if grep -F "$ATTACKER_ROOT" "$PYTHON_LOG" >/dev/null; then
  echo "command-line ROOT redirected repository verification" >&2
  exit 1
fi

: >"$PYTHON_LOG"
run_make lint SHELL=/bin/false PYTHON="$fake_python" >/dev/null
grep -F "$ROOT_DIR/scripts/check_tvos_contracts.py" "$PYTHON_LOG" >/dev/null

: >"$PYTHON_LOG"
run_make lint PYTHON="$fake_python" >/dev/null
grep -F "$ROOT_DIR/scripts/check_tvos_contracts.py" "$PYTHON_LOG" >/dev/null

set +e
run_make lint "PYTHON=\$(shell /usr/bin/touch '$MARKER')python3" >"$TEMP_ROOT/python-syntax.out" 2>"$TEMP_ROOT/python-syntax.err"
python_status=$?
set -e
if [ "$python_status" -eq 0 ] || [ -e "$MARKER" ]; then
  echo "Make-syntax PYTHON override was not rejected safely" >&2
  exit 1
fi
grep -F "PYTHON must be a literal executable path" "$TEMP_ROOT/python-syntax.err" >/dev/null

set +e
run_make lint MAKEFLAGS=--just-print >"$TEMP_ROOT/makeflags.out" 2>"$TEMP_ROOT/makeflags.err"
makeflags_status=$?
set -e
if [ "$makeflags_status" -eq 0 ]; then
  echo "command-line MAKEFLAGS override was not rejected" >&2
  exit 1
fi
grep -F "MAKEFLAGS must not be overridden" "$TEMP_ROOT/makeflags.err" >/dev/null

startup_file=$TEMP_ROOT/startup.mk
printf '%s\n' 'STARTUP_FILE_LOADED := yes' >"$startup_file"
set +e
(cd "$CONTROL_DIR" && MAKEFILES="$startup_file" /usr/bin/make --no-print-directory -f "$MAKEFILE" lint) >"$TEMP_ROOT/makefiles.out" 2>"$TEMP_ROOT/makefiles.err"
makefiles_status=$?
set -e
if [ "$makefiles_status" -eq 0 ]; then
  echo "MAKEFILES startup injection was not rejected" >&2
  exit 1
fi
grep -F "MAKEFILES must be empty" "$TEMP_ROOT/makefiles.err" >/dev/null

set +e
run_make lint PYTHON="$fake_python" MAKEFILE_LIST="$TEMP_ROOT/attacker.mk" >"$TEMP_ROOT/makefile-list.out" 2>"$TEMP_ROOT/makefile-list.err"
makefile_list_status=$?
set -e
if [ "$makefile_list_status" -eq 0 ]; then
  echo "command-line MAKEFILE_LIST override was not rejected" >&2
  exit 1
fi
grep -F "MAKEFILE_LIST must not be overridden" "$TEMP_ROOT/makefile-list.err" >/dev/null

printf '%s\n' "Make authority tests passed: protected root and shell, literal Python override, Make-syntax rejection, MAKEFLAGS/MAKEFILE_LIST rejection, and startup-file rejection"
