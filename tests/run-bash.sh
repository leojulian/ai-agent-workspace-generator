#!/usr/bin/env bash
set -euo pipefail
tests_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bash "$tests_dir/test-public-contract.sh"
bash "$tests_dir/test-set-workspace.sh"
bash "$tests_dir/test-set-env.sh"
printf '[PASS] All Bash tests\n'
