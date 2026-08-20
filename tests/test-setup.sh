#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
case_dir=$(mktemp -d)
trap 'rm -rf -- "$case_dir"' EXIT
cp -- "$root/setup-workspace.sh" "$case_dir/setup-workspace.sh"
cp -- "$root/AGENTS.local.example.md" "$case_dir/AGENTS.local.example.md"
cp -- "$root/.env.example" "$case_dir/.env.example"

bash "$case_dir/setup-workspace.sh" >/dev/null
[[ -f "$case_dir/AGENTS.local.md" && -f "$case_dir/.env" ]]
printf '%s\n' 'LOCAL_SENTINEL' >"$case_dir/AGENTS.local.md"
printf '%s\n' 'TEST_KEY=TEST_ONLY_SENTINEL' >"$case_dir/.env"
bash "$case_dir/setup-workspace.sh" >/dev/null
grep -Fxq 'LOCAL_SENTINEL' "$case_dir/AGENTS.local.md"
grep -Fxq 'TEST_KEY=TEST_ONLY_SENTINEL' "$case_dir/.env"
rm "$case_dir/.env.example"
if bash "$case_dir/setup-workspace.sh" >/dev/null 2>&1; then
	printf '[FAIL] Missing template was accepted\n' >&2
	exit 1
fi
printf '[PASS] Workspace setup\n'
