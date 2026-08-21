# Workspace Generator Agent Instructions

## Rule precedence

1. Follow the user's current instructions first.
2. Follow this repository file and `AGENTS.local.md` when it exists.
3. Load nearer rules before working below a directory that provides its own `AGENTS.md`.

## Repository model

- This repository is a workspace generator, not a generated workspace.
- `set-workspace.bat` and `set-workspace.sh` create or complete a separate workspace directory.
- Files under `templates/common`, `templates/windows`, and `templates/bash` are copied into generated workspaces.
- Keep tool-repository rules separate from generated workspace rules.

## Safe workflow

- Inspect Git status before modifying files; existing changes belong to the user.
- Do not overwrite, revert, clean, or reformat unrelated changes.
- Do not commit, push, merge, switch branches, or update remotes without explicit authorization.
- Never run any form of `git rebase`.
- Preserve existing files in generated workspaces. The generator may only create missing files.

## Template and secret safety

- Never read, search, summarize, copy, hash, print, or upload a real `.env` or `.env.*` file.
- Tests may use only synthetic dotenv data in validated temporary directories.
- `templates/common/env.template` is public template data and must contain empty values only.
- Do not add real credentials, private data, machine paths, or organization-specific information to templates.

## Verification

- Keep Windows cmd.exe and Bash behavior aligned where their platform contracts overlap.
- Run the focused generator and loader tests after script changes.
- Run both complete platform suites before delivery when Windows and WSL are available.
- Report exact files, commands, results, and any platform checks that could not be executed.
