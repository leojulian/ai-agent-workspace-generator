#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
case_dir=$(mktemp -d)
trap 'rm -rf -- "$case_dir"' EXIT
cp -- "$root/set-env.sh" "$case_dir/set-env.sh"
cat >"$case_dir/.env" <<'TEST_ENV'
# synthetic test data
TEST_API_KEY=test-only-value
TEST_VALUE_WITH_EQUALS=left=right==
TEST_EMPTY=
TEST_ENV

previous_dir=$PWD
cd /tmp
source "$case_dir/set-env.sh" >"$case_dir/output.txt" 2>&1
cd "$previous_dir"
[[ $TEST_API_KEY == test-only-value ]]
[[ $TEST_VALUE_WITH_EQUALS == 'left=right==' ]]
[[ ${TEST_EMPTY+x} == x && -z $TEST_EMPTY ]]
! grep -Fq 'test-only-value' "$case_dir/output.txt"
bash -c '[[ $TEST_API_KEY == test-only-value ]]'

set +e
bash "$case_dir/set-env.sh" >"$case_dir/direct-output.txt" 2>&1
direct_status=$?
set -e
[[ $direct_status == 2 ]]
grep -Fq 'source ./set-env.sh' "$case_dir/direct-output.txt"

printf '%s\n' 'BAD-NAME=DO_NOT_PRINT_TEST_VALUE' >"$case_dir/.env"
set +e
source "$case_dir/set-env.sh" >"$case_dir/invalid-output.txt" 2>&1
invalid_status=$?
set -e
[[ $invalid_status == 2 ]]
! grep -Fq 'DO_NOT_PRINT_TEST_VALUE' "$case_dir/invalid-output.txt"

set +e
source "$case_dir/set-env.sh" unexpected-argument >/dev/null 2>&1
argument_status=$?
set -e
[[ $argument_status == 2 ]]
printf '[PASS] Bash environment loader\n'
