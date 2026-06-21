#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(/usr/bin/dirname -- "$0")/.." && /bin/pwd -P)
MAKEFILE=$ROOT_DIR/Makefile
WRAPPER=$ROOT_DIR/scripts/run-make.sh
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/tvos-make-authority-XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM

CONTROL_DIR=$TEMP_ROOT/control
PYTHON_LOG=$TEMP_ROOT/python.log
mkdir -p "$CONTROL_DIR"

fake_python=$TEMP_ROOT/python-safe
cat >"$fake_python" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"$PYTHON_LOG"
exit 0
EOF
chmod +x "$fake_python"

failing_python=$TEMP_ROOT/python-failing
cat >"$failing_python" <<'EOF'
#!/bin/sh
exit 7
EOF
chmod +x "$failing_python"

FAKE_BIN=$TEMP_ROOT/bin
mkdir -p "$FAKE_BIN"
cat >"$FAKE_BIN/xcodebuild" <<'EOF'
#!/bin/sh
exit 0
EOF
chmod +x "$FAKE_BIN/xcodebuild"

raw_make() {
  (cd "$CONTROL_DIR" && /usr/bin/make --no-print-directory "$@")
}

if command -v gmake >/dev/null 2>&1; then
  GNU_MAKE=$(command -v gmake)
elif /usr/bin/make --version 2>/dev/null | grep -F 'GNU Make 4.' >/dev/null; then
  GNU_MAKE=/usr/bin/make
else
  GNU_MAKE=
fi

if [ -n "$GNU_MAKE" ]; then
  : >"$PYTHON_LOG"
  (cd "$CONTROL_DIR" && "$GNU_MAKE" --no-print-directory -n \
    --eval='override MAKEFLAGS :=' -f "$MAKEFILE" lint PYTHON="$fake_python") \
    >"$TEMP_ROOT/raw-dry-run.out" 2>"$TEMP_ROOT/raw-dry-run.err"
  if [ -s "$PYTHON_LOG" ]; then
    echo "raw GNU Make dry-run unexpectedly executed verification" >&2
    exit 1
  fi

  (cd "$CONTROL_DIR" && "$GNU_MAKE" --no-print-directory -i \
    --eval='override MAKEFLAGS :=' -f "$MAKEFILE" lint PYTHON="$failing_python") \
    >"$TEMP_ROOT/raw-ignore.out" 2>"$TEMP_ROOT/raw-ignore.err"

  gnumake_marker=$TEMP_ROOT/gnumakeflags-executed
  GNUMAKEFLAGS="--eval=GNUMAKE_MARKER:=\$(shell /usr/bin/touch '$gnumake_marker')" \
    "$GNU_MAKE" --no-print-directory -f "$MAKEFILE" lint PYTHON="$fake_python" \
    >"$TEMP_ROOT/raw-gnumakeflags.out" 2>"$TEMP_ROOT/raw-gnumakeflags.err"
  if [ ! -e "$gnumake_marker" ]; then
    echo "raw GNUMAKEFLAGS did not reproduce pre-parse execution" >&2
    exit 1
  fi
fi

startup_marker=$TEMP_ROOT/startup-executed
startup_file=$TEMP_ROOT/startup.mk
cat >"$startup_file" <<EOF
\$(shell /usr/bin/touch '$startup_marker')
override MAKEFILES :=
EOF
MAKEFILES="$startup_file" raw_make -f "$MAKEFILE" lint PYTHON="$fake_python" \
  >"$TEMP_ROOT/raw-startup.out" 2>"$TEMP_ROOT/raw-startup.err"
if [ ! -e "$startup_marker" ]; then
  echo "raw MAKEFILES did not reproduce startup execution" >&2
  exit 1
fi

earlier_marker=$TEMP_ROOT/earlier-makefile-executed
earlier_makefile=$TEMP_ROOT/earlier.mk
printf '%s\n' "\$(shell /usr/bin/touch '$earlier_marker')" >"$earlier_makefile"
raw_make -f "$earlier_makefile" -f "$MAKEFILE" lint PYTHON="$fake_python" \
  >"$TEMP_ROOT/raw-earlier-f.out" 2>"$TEMP_ROOT/raw-earlier-f.err"
if [ ! -e "$earlier_marker" ]; then
  echo "raw earlier -f did not reproduce pre-parse execution" >&2
  exit 1
fi

if [ ! -x "$WRAPPER" ]; then
  echo "trusted Make wrapper is missing or not executable: $WRAPPER" >&2
  exit 1
fi

expect_rejected() {
  name=$1
  shift
  set +e
  (cd "$CONTROL_DIR" && "$WRAPPER" "$@") \
    >"$TEMP_ROOT/$name.out" 2>"$TEMP_ROOT/$name.err"
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then
    echo "wrapper accepted hostile invocation: $name" >&2
    exit 1
  fi
}

expect_rejected dry-run -n --eval='override MAKEFLAGS :=' check
expect_rejected ignore-errors -i --eval='override MAKEFLAGS :=' test
expect_rejected earlier-makefile -f "$earlier_makefile" -f "$MAKEFILE" test
expect_rejected make-assignment MAKEFLAGS=--just-print test
expect_rejected extra-target test check

rm -f "$startup_marker" "$gnumake_marker"
: >"$PYTHON_LOG"
MAKEFILES="$startup_file" \
MAKEFLAGS=--just-print \
MFLAGS=-n \
MAKEOVERRIDES=attacker \
GNUMAKEFLAGS="--eval=GNUMAKE_MARKER:=\$(shell /usr/bin/touch '$gnumake_marker')" \
PYTHON="$fake_python" \
PATH="$FAKE_BIN:/usr/bin:/bin" \
  "$WRAPPER" test >"$TEMP_ROOT/wrapped-environment.out" 2>"$TEMP_ROOT/wrapped-environment.err"

if [ -e "$startup_marker" ] || [ -e "$gnumake_marker" ]; then
  echo "wrapper allowed inherited Make startup authority" >&2
  exit 1
fi
grep -F "$ROOT_DIR/scripts/check_tvos_contracts.py" "$PYTHON_LOG" >/dev/null

printf '%s\n' \
  "Make authority tests passed: raw pre-parse paths reproduced; wrapper rejected options, assignments, extra args, earlier -f files, and cleared inherited Make controls"
