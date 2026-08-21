#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
case_dir=$(mktemp -d)
trap 'rm -rf -- "$case_dir"' EXIT
tool_dir="$case_dir/tool"
workspace_parent="$case_dir/workspaces"
mkdir -p -- "$tool_dir"
cp -- "$root/set-workspace.sh" "$tool_dir/set-workspace.sh"
cp -R -- "$root/templates" "$tool_dir/templates"

bash "$tool_dir/set-workspace.sh" "$workspace_parent" workspace-one >/dev/null
target="$workspace_parent/workspace-one"
for file in AGENTS.md AGENTS.local.md CLAUDE.md GEMINI.md .env set-env.sh; do
	[[ -f "$target/$file" ]] || {
		printf '[FAIL] Missing generated file: %s\n' "$file" >&2
		exit 1
	}
done
for file in set-env.bat .gitignore README.md README.en.md; do
	[[ ! -e "$target/$file" ]] || {
		printf '[FAIL] Unexpected generated file: %s\n' "$file" >&2
		exit 1
	}
done
[[ ! -e "$target/.git" ]]
grep -Fxq 'OPENAI_API_KEY=' "$target/.env"
grep -Fxq 'ANTHROPIC_API_KEY=' "$target/.env"
grep -Fxq 'GEMINI_API_KEY=' "$target/.env"

printf '%s\n' 'LOCAL_SENTINEL' >"$target/AGENTS.local.md"
printf '%s\n' 'TEST_KEY=TEST_ONLY_SENTINEL' >"$target/.env"
mkdir -p -- "$target/project-a"
bash "$tool_dir/set-workspace.sh" "$workspace_parent" workspace-one >"$case_dir/repeat-output.txt"
grep -Fxq 'LOCAL_SENTINEL' "$target/AGENTS.local.md"
grep -Fxq 'TEST_KEY=TEST_ONLY_SENTINEL' "$target/.env"
[[ -d "$target/project-a" ]]
grep -Fq '[notice] Existing AGENTS.md was preserved.' "$case_dir/repeat-output.txt"
grep -Fq '[notice] Verify that it loads AGENTS.local.md and nearer project-level AGENTS.md files.' "$case_dir/repeat-output.txt"

printf '%s\n%s\n' "$workspace_parent" interactive-workspace | bash "$tool_dir/set-workspace.sh" >/dev/null
[[ -f "$workspace_parent/interactive-workspace/set-env.sh" ]]
bash "$tool_dir/set-workspace.sh" "$workspace_parent" 'workspace with spaces' >/dev/null
[[ -f "$workspace_parent/workspace with spaces/set-env.sh" ]]

if bash "$tool_dir/set-workspace.sh" "$workspace_parent" '../escape' >/dev/null 2>&1; then
	printf '[FAIL] Invalid workspace name was accepted\n' >&2
	exit 1
fi

rm -- "$tool_dir/templates/common/AGENTS.md"
if bash "$tool_dir/set-workspace.sh" "$workspace_parent" missing-template >/dev/null 2>&1; then
	printf '[FAIL] Missing template was accepted\n' >&2
	exit 1
fi
[[ ! -e "$workspace_parent/missing-template" ]]
printf '[PASS] Bash workspace generator\n'
