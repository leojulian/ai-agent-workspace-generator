#!/usr/bin/env bash
set -u

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
failed=0

usage() {
	printf 'Usage: %s [workspace-parent workspace-name]\n' "${0##*/}" >&2
}

if (($# == 0)); then
	printf 'Workspace parent directory: '
	IFS= read -r workspace_parent || exit 2
	printf 'Workspace name: '
	IFS= read -r workspace_name || exit 2
elif (($# == 2)); then
	workspace_parent=$1
	workspace_name=$2
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
platform_loader="$root/templates/bash/set-env.sh"
required=(
	"$common_dir/AGENTS.md"
	"$common_dir/AGENTS.local.md"
	"$common_dir/CLAUDE.md"
	"$common_dir/GEMINI.md"
	"$common_dir/env.template"
	"$platform_loader"
)
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

copy_if_missing "$common_dir/AGENTS.md" AGENTS.md
copy_if_missing "$common_dir/AGENTS.local.md" AGENTS.local.md
copy_if_missing "$common_dir/CLAUDE.md" CLAUDE.md
copy_if_missing "$common_dir/GEMINI.md" GEMINI.md
copy_if_missing "$common_dir/env.template" .env
copy_if_missing "$platform_loader" set-env.sh

if ((failed == 0)); then
	if ((existing_agents == 1)); then
		printf '[notice] Existing AGENTS.md was preserved.\n'
		printf '[notice] Verify that it loads AGENTS.local.md and nearer project-level AGENTS.md files.\n'
	fi
	printf '[ready] workspace: %s\n' "$target"
fi
exit "$failed"
