#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
case_dir=$(mktemp -d)
trap 'rm -rf -- "$case_dir"' EXIT
for file in AGENTS.md AGENTS.local.example.md CLAUDE.md GEMINI.md .env.example .gitignore setup-workspace.bat setup-workspace.sh set-env.bat set-env.sh check-workspace.bat check-workspace.sh; do
	cp -- "$root/$file" "$case_dir/$file"
done
printf '# Synthetic test repository\n' >"$case_dir/README.md"
git -C "$case_dir" init -q
bash "$case_dir/check-workspace.sh" >/dev/null
printf '%s\n' 'TEST_KEY=test-only-value' >"$case_dir/.env.production"
git -C "$case_dir" add -f -- .env.production
if bash "$case_dir/check-workspace.sh" >/dev/null 2>&1; then
	printf '[FAIL] Tracked private dotenv was accepted\n' >&2
	exit 1
fi
git -C "$case_dir" rm --cached -q -- .env.production
bash "$case_dir/check-workspace.sh" >/dev/null
printf '%s\n' '.env.example' >>"$case_dir/.gitignore"
if bash "$case_dir/check-workspace.sh" >/dev/null 2>&1; then
	printf '[FAIL] Ignored public example was accepted\n' >&2
	exit 1
fi
printf '[PASS] Bash workspace checker\n'
