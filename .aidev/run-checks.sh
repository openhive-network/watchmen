#!/usr/bin/env bash
# Run the checks named after the suite and write test-results/<suite>/junit.xml.
#
#   .aidev/run-checks.sh <suite> <step>...
#
# The repository has no test suite; these are the checks its scripts allow.
# Steps, one junit case each:
#
#   syntax   `bash -n` of every scripts/*.sh (one case per script)
#   compile  scripts/compile_badactors.sh on a copy of scripts/ and input/,
#            then: the committed output/flat/badactors.txt holds exactly the
#            accounts the inputs compile to. Compared as sorted sets, because
#            the committed file is sorted in the maintainer's locale
#            (en_US.UTF-8) and the image has only the C collation.
#
# Not run: scripts/validate-community-mr.sh (CI's advisory
# validate-community-submission job) diffs an MR against origin/main, which a
# gate's checkout does not have; scripts/update_inputs.sh downloads upstream
# lists (network).
#
# Runs offline in the image of .aidev/runtime/Dockerfile.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
root="$PWD"
suite="${1:?usage: $0 <suite> <step>...}"; shift
out="$root/test-results/$suite"
rm -rf "$out"; mkdir -p "$out"
cases=()
status=0

xml_escape() { tr -d '\000-\010\013\014\016-\037' | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'; }

# record NAME pass|fail SECONDS LOG
record() {
    local name="$1" result="$2" secs="$3" log="$4" body
    if [ "$result" = pass ]; then
        cases+=("<testcase classname=\"watchmen.$suite\" name=\"$name\" time=\"$secs\"></testcase>")
    else
        body="$(tail -n 80 "$log" | xml_escape)"
        cases+=("<testcase classname=\"watchmen.$suite\" name=\"$name\" time=\"$secs\"><failure message=\"$name failed\">$body</failure></testcase>")
        status=1
    fi
}

# run NAME CMD... — run CMD with its output shown and logged, record a case
run() {
    local name="$1"; shift
    local log="$out/${name//\//_}.log" start rc
    start=$SECONDS
    echo "=== $name: $* ==="
    (cd "$root" && "$@") > >(tee "$log") 2>&1 < /dev/null; rc=$?
    record "$name" "$([ "$rc" -eq 0 ] && echo pass || echo fail)" "$((SECONDS - start))" "$log"
    return "$rc"
}

compile_check() {
    local tmp rc=0
    tmp="$(mktemp -d)"
    cp -r scripts input "$tmp/" || return 1
    bash "$tmp/scripts/compile_badactors.sh" || { rm -rf "$tmp"; return 1; }
    if ! diff <(LC_ALL=C sort -u output/flat/badactors.txt) <(LC_ALL=C sort -u "$tmp/output/flat/badactors.txt"); then
        echo "output/flat/badactors.txt differs from what scripts/compile_badactors.sh makes of input/ (< committed, > compiled); rerun the script and commit its output"
        rc=1
    fi
    rm -rf "$tmp"
    return "$rc"
}

for step in "$@"; do
    case "$step" in
        syntax)
            for f in scripts/*.sh; do run "syntax/$(basename "$f")" bash -n "$f"; done
            ;;
        compile) run compile compile_check ;;
        *)
            echo "unknown step: $step" > "$out/$step.log"
            record "$step" fail 0 "$out/$step.log"
            ;;
    esac
done

failures=0
for c in "${cases[@]}"; do case "$c" in *"<failure"*) failures=$((failures + 1));; esac; done
{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo "<testsuite name=\"watchmen.$suite\" tests=\"${#cases[@]}\" failures=\"$failures\" errors=\"0\" skipped=\"0\">"
    printf '%s\n' "${cases[@]}"
    echo '</testsuite>'
} > "$out/junit.xml"
echo "junit: $out/junit.xml (${#cases[@]} cases, $failures failed)"
exit "$status"
