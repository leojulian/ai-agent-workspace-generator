#!/usr/bin/env bash
set -euo pipefail
tests_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bash "$tests_dir/test-public-contract.sh"
bash "$tests_dir/test-setup.sh"
bash "$tests_dir/test-set-env.sh"
bash "$tests_dir/test-check-workspace.sh"
printf '[PASS] All Bash tests\n'
