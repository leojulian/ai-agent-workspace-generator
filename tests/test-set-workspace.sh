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
for file in AGENTS.md AGENTS.local.md .env set-env.sh; do
	[[ -f "$target/$file" ]] || {
		printf '[FAIL] Missing generated file: %s\n' "$file" >&2
		exit 1
	}
done
for file in set-env.bat .gitignore README.md README.en.md CLAUDE.md GEMINI.md AGENTS.cn.md AGENTS.local.cn.md CLAUDE.cn.md GEMINI.cn.md; do
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
printf '%s\n' 'EXISTING_CLAUDE_SENTINEL' >"$target/CLAUDE.md"
printf '%s\n' 'EXISTING_GEMINI_SENTINEL' >"$target/GEMINI.md"
bash "$tool_dir/set-workspace.sh" "$workspace_parent" workspace-one >"$case_dir/repeat-output.txt"
grep -Fxq 'LOCAL_SENTINEL' "$target/AGENTS.local.md"
grep -Fxq 'TEST_KEY=TEST_ONLY_SENTINEL' "$target/.env"
[[ -d "$target/project-a" ]]
grep -Fxq 'EXISTING_CLAUDE_SENTINEL' "$target/CLAUDE.md"
grep -Fxq 'EXISTING_GEMINI_SENTINEL' "$target/GEMINI.md"
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
if bash "$tool_dir/set-workspace.sh" "$workspace_parent" too-many en extra >/dev/null 2>&1; then
	printf '[FAIL] Too many arguments were accepted\n' >&2
	exit 1
fi
[[ ! -e "$workspace_parent/too-many" ]]

for file in AGENTS.md AGENTS.local.md; do
	cmp -s "$workspace_parent/interactive-workspace/$file" "$tool_dir/templates/common/$file" || {
		printf '[FAIL] Missing language answer did not fall back to English: %s\n' "$file" >&2
		exit 1
	}
done

bash "$tool_dir/set-workspace.sh" "$workspace_parent" workspace-zh zh-CN >"$case_dir/zh-output.txt"
zh_target="$workspace_parent/workspace-zh"
for file in AGENTS.md AGENTS.local.md; do
	cmp -s "$zh_target/$file" "$tool_dir/templates/common/${file%.md}.cn.md" || {
		printf '[FAIL] Chinese rule document mismatch: %s\n' "$file" >&2
		exit 1
	}
done
grep -Fxq '# Agent 行为与工作区协作规则' "$zh_target/AGENTS.md"
grep -Fq 'AGENTS.local.md' "$zh_target/AGENTS.md"
grep -Fq '[language] rule documents: zh-CN' "$case_dir/zh-output.txt"
for file in CLAUDE.md GEMINI.md; do
	[[ ! -e "$zh_target/$file" ]] || {
		printf '[FAIL] Unexpected generated entry document: %s\n' "$file" >&2
		exit 1
	}
done

bash "$tool_dir/set-workspace.sh" "$workspace_parent" workspace-zh-alias zh >/dev/null
cmp -s "$workspace_parent/workspace-zh-alias/AGENTS.md" "$tool_dir/templates/common/AGENTS.cn.md" || {
	printf '[FAIL] Language alias zh did not select Chinese rules\n' >&2
	exit 1
}

bash "$tool_dir/set-workspace.sh" "$workspace_parent" workspace-en en >"$case_dir/en-output.txt"
cmp -s "$workspace_parent/workspace-en/AGENTS.md" "$tool_dir/templates/common/AGENTS.md" || {
	printf '[FAIL] Explicit en did not select English rules\n' >&2
	exit 1
}
grep -Fq '[language] rule documents: en' "$case_dir/en-output.txt"

printf '%s\n%s\n%s\n' "$workspace_parent" interactive-zh zh-CN | bash "$tool_dir/set-workspace.sh" >/dev/null
cmp -s "$workspace_parent/interactive-zh/AGENTS.md" "$tool_dir/templates/common/AGENTS.cn.md" || {
	printf '[FAIL] Interactive language selection did not select Chinese rules\n' >&2
	exit 1
}

printf '%s\n%s\n%s' "$workspace_parent" interactive-zh-eof zh-CN | bash "$tool_dir/set-workspace.sh" >"$case_dir/zh-eof-output.txt"
for file in AGENTS.md AGENTS.local.md; do
	cmp -s "$workspace_parent/interactive-zh-eof/$file" "$tool_dir/templates/common/${file%.md}.cn.md" || {
		printf '[FAIL] Language input without a final newline was discarded: %s\n' "$file" >&2
		exit 1
	}
done
grep -Fq '[language] rule documents: zh-CN' "$case_dir/zh-eof-output.txt"

bash "$tool_dir/set-workspace.sh" "$workspace_parent" workspace-empty-language '' >"$case_dir/empty-language-output.txt"
for file in AGENTS.md AGENTS.local.md; do
	cmp -s "$workspace_parent/workspace-empty-language/$file" "$tool_dir/templates/common/$file"
done
grep -Fq '[language] rule documents: en' "$case_dir/empty-language-output.txt"

invalid_parent="$case_dir/invalid-language-parent"
for language_input in $'klingon\n' klingon $'klingon\n\nzh-CN\n'; do
	status=0
	printf '%s\n%s\n%s' "$invalid_parent" invalid-workspace "$language_input" |
		bash "$tool_dir/set-workspace.sh" >"$case_dir/invalid-retry-output.txt" 2>&1 || status=$?
	if [[ $status != 2 ]]; then
		printf '[FAIL] Empty retry after invalid language returned %s instead of 2\n' "$status" >&2
		exit 1
	fi
	[[ ! -e "$invalid_parent" ]] || {
		printf '[FAIL] Invalid language retry created a workspace parent\n' >&2
		exit 1
	}
	if grep -Fq -e '[ready]' -e '[created]' "$case_dir/invalid-retry-output.txt"; then
		printf '[FAIL] Invalid language retry reported success\n' >&2
		exit 1
	fi
done

printf '%s\n%s\n%s\n%s' "$workspace_parent" corrected-language klingon zh-CN |
	bash "$tool_dir/set-workspace.sh" >"$case_dir/corrected-output.txt" 2>&1
grep -Fq '[failed] unsupported rule language: klingon' "$case_dir/corrected-output.txt"
cmp -s "$workspace_parent/corrected-language/AGENTS.md" "$tool_dir/templates/common/AGENTS.cn.md"

if bash "$tool_dir/set-workspace.sh" "$workspace_parent" bad-language klingon >/dev/null 2>&1; then
	printf '[FAIL] Unsupported rule language was accepted\n' >&2
	exit 1
fi
[[ ! -e "$workspace_parent/bad-language" ]]

rm -- "$tool_dir/templates/common/AGENTS.local.cn.md"
if bash "$tool_dir/set-workspace.sh" "$workspace_parent" missing-zh zh-CN >/dev/null 2>&1; then
	printf '[FAIL] Missing Chinese template was accepted\n' >&2
	exit 1
fi
[[ ! -e "$workspace_parent/missing-zh" ]]
bash "$tool_dir/set-workspace.sh" "$workspace_parent" missing-zh-en >/dev/null
[[ -f "$workspace_parent/missing-zh-en/AGENTS.local.md" ]]

rm -- "$tool_dir/templates/common/AGENTS.md"
if bash "$tool_dir/set-workspace.sh" "$workspace_parent" missing-template >/dev/null 2>&1; then
	printf '[FAIL] Missing template was accepted\n' >&2
	exit 1
fi
[[ ! -e "$workspace_parent/missing-template" ]]
printf '[PASS] Bash workspace generator\n'
