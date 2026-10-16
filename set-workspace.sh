#!/usr/bin/env bash
set -u

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
failed=0

usage() {
	printf 'Usage: %s [workspace-parent workspace-name [rule-language]]\n' "${0##*/}" >&2
	printf 'Rule language: en (default) or zh-CN\n' >&2
}

normalize_language() {
	case $(printf '%s' "$1" | tr '[:upper:]' '[:lower:]') in
	en | en-us | english) printf 'en' ;;
	zh | zh-cn | zh-hans | chinese) printf 'zh-CN' ;;
	*) return 1 ;;
	esac
}

# Sets the global `language`; only the initial prompt permits an empty answer.
prompt_language() {
	local answer require_answer=0
	while :; do
		if ((require_answer)); then
			printf 'Rule documents language [en/zh-CN]: '
		else
			printf 'Rule documents language [en/zh-CN] (en): '
		fi
		IFS= read -r answer || :
		if [[ -z $answer ]]; then
			if ((require_answer)); then
				printf '[failed] rule language is required after an unsupported value\n' >&2
				return 2
			fi
			language=en
			return 0
		fi
		if language=$(normalize_language "$answer"); then
			return 0
		fi
		printf '[failed] unsupported rule language: %s (expected en or zh-CN)\n' "$answer" >&2
		require_answer=1
	done
}

if (($# == 0)); then
	printf 'Workspace parent directory: '
	IFS= read -r workspace_parent || exit 2
	printf 'Workspace name: '
	IFS= read -r workspace_name || exit 2
	prompt_language || exit 2
elif (($# == 2 || $# == 3)); then
	workspace_parent=$1
	workspace_name=$2
	if ! language=$(normalize_language "${3:-en}"); then
		printf '[failed] unsupported rule language: %s (expected en or zh-CN)\n' "$3" >&2
		exit 2
	fi
else
	usage
	exit 2
fi

if [[ -z $workspace_parent ]]; then
	printf '[failed] workspace parent directory must not be empty\n' >&2
	exit 2
fi
if [[ -z $workspace_name || $workspace_name == . || $workspace_name == .. || $workspace_name == */* || $workspace_name == *\\* ]]; then
	printf '[failed] workspace name must be a single directory name\n' >&2
	exit 2
fi

common_dir="$root/templates/common"
rule_documents=(AGENTS.md AGENTS.local.md CLAUDE.md GEMINI.md)
platform_loader="$root/templates/bash/set-env.sh"

# English rule documents live in templates/common; the Chinese ones live in the
# repository root with a .cn.md suffix.
rule_source_path() {
	if [[ $language == en ]]; then
		printf '%s/%s' "$common_dir" "$1"
	else
		printf '%s/%s.cn.md' "$root" "${1%.md}"
	fi
}

required=(
	"$common_dir/env.template"
	"$platform_loader"
)
for document in "${rule_documents[@]}"; do
	required+=("$(rule_source_path "$document")")
done
for source_path in "${required[@]}"; do
	if [[ ! -f $source_path ]]; then
		printf '[failed] missing template: %s\n' "${source_path#"$root/"}" >&2
		failed=1
	fi
done
((failed == 0)) || exit 1

target="$workspace_parent/$workspace_name"
existing_agents=0
[[ -e $target/AGENTS.md ]] && existing_agents=1
if ! mkdir -p -- "$target"; then
	printf '[failed] could not create workspace: %s\n' "$target" >&2
	exit 1
fi

copy_if_missing() {
	local source_path=$1
	local target_name=$2
	if [[ -e $target/$target_name ]]; then
		printf '[skipped] %s already exists\n' "$target_name"
		return 0
	fi
	if cp -- "$source_path" "$target/$target_name"; then
		printf '[created] %s\n' "$target_name"
	else
		printf '[failed] could not create: %s\n' "$target_name" >&2
		failed=1
	fi
}

for document in "${rule_documents[@]}"; do
	copy_if_missing "$(rule_source_path "$document")" "$document"
done
copy_if_missing "$common_dir/env.template" .env
copy_if_missing "$platform_loader" set-env.sh

if ((failed == 0)); then
	if ((existing_agents == 1)); then
		printf '[notice] Existing AGENTS.md was preserved.\n'
		printf '[notice] Verify that it loads AGENTS.local.md and nearer project-level AGENTS.md files.\n'
	fi
	printf '[language] rule documents: %s\n' "$language"
	printf '[ready] workspace: %s\n' "$target"
fi
exit "$failed"
