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

run_wrapper_with_zero() {
  synthetic_zero=$1
  shift
  /bin/sh -c 'wrapper=$1; shift; . "$wrapper"' "$synthetic_zero" "$WRAPPER" "$@"
}

expect_rejected dry-run -n --eval='override MAKEFLAGS :=' check
expect_rejected ignore-errors -i --eval='override MAKEFLAGS :=' test
expect_rejected earlier-makefile -f "$earlier_makefile" -f "$MAKEFILE" test
expect_rejected make-assignment MAKEFLAGS=--just-print test
expect_rejected extra-target test check

SYMLINK_ROOT=$TEMP_ROOT/symlink-checkout
SYMLINK_MARKER=$TEMP_ROOT/symlink-root-executed
mkdir -p "$SYMLINK_ROOT/scripts"
cat >"$SYMLINK_ROOT/Makefile" <<EOF
check test:
	@/usr/bin/touch '$SYMLINK_MARKER'
EOF
ln -s "$WRAPPER" "$SYMLINK_ROOT/scripts/run-make.sh"
if ! (cd "$CONTROL_DIR" && PYTHON="$fake_python" PATH="$FAKE_BIN:/usr/bin:/bin" \
  /bin/sh "$SYMLINK_ROOT/scripts/run-make.sh" test) \
  >"$TEMP_ROOT/symlink-root.out" 2>"$TEMP_ROOT/symlink-root.err"; then
  echo "wrapper failed through an external symlink" >&2
  exit 1
fi
if [ -e "$SYMLINK_MARKER" ]; then
  echo "external symlink redirected trusted Make root" >&2
  exit 1
fi

MIXED_SYMLINK_ROOT=$TEMP_ROOT/mixed-symlink-checkout
MIXED_SYMLINK_MARKER=$TEMP_ROOT/mixed-symlink-root-executed
MIXED_TARGET_NAME="physical target's
middle"
mkdir -p "$MIXED_SYMLINK_ROOT/scripts"
cat >"$MIXED_SYMLINK_ROOT/Makefile" <<EOF
check test:
	@/usr/bin/touch '$MIXED_SYMLINK_MARKER'
EOF
ln -s "$WRAPPER" "$MIXED_SYMLINK_ROOT/scripts/$MIXED_TARGET_NAME"
ln -s "$MIXED_TARGET_NAME" "$MIXED_SYMLINK_ROOT/scripts/run-make.sh"
if ! (cd "$CONTROL_DIR" && PYTHON="$fake_python" PATH="$FAKE_BIN:/usr/bin:/bin" \
  /bin/sh "$MIXED_SYMLINK_ROOT/scripts/run-make.sh" test) \
  >"$TEMP_ROOT/mixed-symlink-root.out" 2>"$TEMP_ROOT/mixed-symlink-root.err"; then
  echo "wrapper failed through a relative symlink containing spaces, quotes, and a newline" >&2
  exit 1
fi
if [ -e "$MIXED_SYMLINK_MARKER" ]; then
  echo "mixed-byte symlink redirected trusted Make root" >&2
  exit 1
fi

BROKEN_SYMLINK_ROOT=$TEMP_ROOT/broken-symlink-checkout
BROKEN_SYMLINK_MARKER=$TEMP_ROOT/broken-symlink-root-executed
mkdir -p "$BROKEN_SYMLINK_ROOT/scripts"
cat >"$BROKEN_SYMLINK_ROOT/Makefile" <<EOF
check test:
	@/usr/bin/touch '$BROKEN_SYMLINK_MARKER'
EOF
ln -s missing-target "$BROKEN_SYMLINK_ROOT/scripts/run-make.sh"
if (cd "$CONTROL_DIR" && run_wrapper_with_zero "$BROKEN_SYMLINK_ROOT/scripts/run-make.sh" check) \
  >"$TEMP_ROOT/broken-symlink.out" 2>"$TEMP_ROOT/broken-symlink.err"; then
  echo "broken symlink invocation unexpectedly succeeded" >&2
  exit 1
fi
if [ -e "$BROKEN_SYMLINK_MARKER" ]; then
  echo "broken symlink invocation executed an external Makefile" >&2
  exit 1
fi

OVERLONG_SYMLINK_ROOT=$TEMP_ROOT/overlong-symlink-checkout
OVERLONG_SYMLINK_MARKER=$TEMP_ROOT/overlong-symlink-root-executed
mkdir -p "$OVERLONG_SYMLINK_ROOT/scripts"
cat >"$OVERLONG_SYMLINK_ROOT/Makefile" <<EOF
check test:
	@/usr/bin/touch '$OVERLONG_SYMLINK_MARKER'
EOF
ln -s "$WRAPPER" "$OVERLONG_SYMLINK_ROOT/scripts/link-41"
link_number=40
while [ "$link_number" -ge 1 ]; do
  next_link=$((link_number + 1))
  ln -s "link-$next_link" "$OVERLONG_SYMLINK_ROOT/scripts/link-$link_number"
  link_number=$((link_number - 1))
done
ln -s link-1 "$OVERLONG_SYMLINK_ROOT/scripts/run-make.sh"
if (cd "$CONTROL_DIR" && run_wrapper_with_zero "$OVERLONG_SYMLINK_ROOT/scripts/run-make.sh" check) \
  >"$TEMP_ROOT/overlong-symlink.out" 2>"$TEMP_ROOT/overlong-symlink.err"; then
  echo "overlong symlink invocation unexpectedly succeeded" >&2
  exit 1
fi
if [ -e "$OVERLONG_SYMLINK_MARKER" ]; then
  echo "overlong symlink invocation executed an external Makefile" >&2
  exit 1
fi

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
  "Make authority tests passed: raw pre-parse paths reproduced; wrapper resolved its physical script, rejected broken/overlong links, options, assignments, extra args, earlier -f files, and cleared inherited Make controls"
